import argparse
import json
import logging
from pathlib import Path
import re
import signal
import subprocess
import sys
import threading
from typing import Optional

import httpx

from audio import AudioRecorder
import backend
from config import atomic_write_text, load_config
import injector
from ipc import IPCServer, send_ipc_command, stream_ipc_events
from models import StateResponse

logger = logging.getLogger("noctalia-dictation")


def _extract_json_payload(raw: str) -> dict:
    """Extract JSON object from LLM response, stripping markdown fences if present."""
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
        cleaned = re.sub(r"\s*```$", "", cleaned)
        cleaned = cleaned.strip()
    return json.loads(cleaned)


def _truncate_word_boundary(text: str, max_chars: int) -> str:
    """Safely truncate text at word boundaries rather than breaking words in half."""
    if len(text) <= max_chars:
        return text
    truncated = text[:max_chars]
    last_space = max(truncated.rfind(" "), truncated.rfind("\n"))
    if last_space > int(max_chars * 0.7):
        return truncated[:last_space].strip()
    return truncated.strip()


class DictationService:
    def __init__(self):
        self.config = load_config()
        self.current_state = StateResponse(state="idle")
        self.lock = threading.RLock()
        self.stop_event = threading.Event()
        self.correction_count = 0
        self.last_dictation: Optional[dict[str, str]] = None
        self._is_learning_running = False
        self._learning_lock = threading.Lock()
        self.recorder = AudioRecorder(
            sample_rate=self.config.sample_rate,
            silence_seconds=self.config.silence_duration_seconds,
            vad_aggressiveness=self.config.vad_aggressiveness,
            on_silence=self._on_silence_detected,
        )

        self.ipc_server = IPCServer(
            on_command=self.handle_ipc_command,
            get_current_state=self.get_state,
        )

    def get_state(self) -> StateResponse:
        with self.lock:
            return self.current_state

    def _set_state(
        self,
        state: str,
        error: Optional[str] = None,
    ) -> None:
        new_state = StateResponse(
            state=state,
            error=error,
        )
        with self.lock:
            self.current_state = new_state
        self.ipc_server.broadcast(new_state)

    def start(self) -> None:
        self.ipc_server.start()
        logger.info(
            "noctalia-dictation daemon started. Models: %s + %s",
            self.config.stt_model,
            self.config.refinement_model,
        )

    def handle_ipc_command(self, cmd: str) -> str:
        cmd = cmd.strip().lower()
        if cmd == "toggle":
            self.toggle()
            return f"ok: toggled, current state is {self.current_state.state}"
        elif cmd == "stop":
            self.stop_recording()
            return "ok: stopped"
        elif cmd == "capture-correction":
            return self.capture_correction()
        return f"error: unknown command '{cmd}'"

    def _on_silence_detected(self) -> None:
        with self.lock:
            if self.current_state.state == "recording":
                logger.info("Silence detected, finishing recording...")
                self._stop_and_process()

    def toggle(self) -> None:
        with self.lock:
            state = self.current_state.state
            if state == "idle":
                self._start_recording()
            elif state == "recording":
                self._stop_and_process()
            elif state == "processing":
                logger.info("Already processing previous request...")

    def stop_recording(self) -> None:
        with self.lock:
            if self.current_state.state == "recording":
                self._stop_and_process()

    def _start_recording(self) -> None:
        self._set_state("recording")
        logger.info("Recording started...")
        self.recorder.start()

    def _stop_and_process(self) -> None:
        self._set_state("processing")
        wav_bytes = self.recorder.stop()

        # Minimum audio length check (~0.4s)
        min_bytes = int(self.config.sample_rate * 0.4 * 2)
        if len(wav_bytes) < min_bytes:
            logger.info("Audio too short, cancelled.")
            self._set_state("idle")
            return

        logger.info("Processing %d bytes audio via Groq...", len(wav_bytes))
        threading.Thread(target=self._process_worker, args=(wav_bytes,), daemon=True).start()

    def _process_worker(self, wav_bytes: bytes) -> None:
        try:
            refined_text, raw_text = backend.transcribe_and_refine_full(wav_bytes, self.config)
            if refined_text:
                logger.info("Result: %s", refined_text)
                with self.lock:
                    self.last_dictation = {
                        "raw": raw_text,
                        "refined": refined_text,
                    }
                injector.inject_text(refined_text)
            else:
                logger.info("No speech recognized.")
            self._set_state("idle")
        except Exception as e:
            err_msg = str(e)
            logger.error("Error processing speech: %s", err_msg, exc_info=True)
            self._set_state("idle", error=err_msg)

    def capture_correction(self) -> str:
        with self.lock:
            if not self.last_dictation:
                return "ignored: no recent dictation to correct"

            try:
                proc = subprocess.run(
                    ["wl-paste", "--no-newline"],
                    capture_output=True,
                    text=True,
                    timeout=2.0,
                    check=True,
                )
                corrected_text = proc.stdout.strip()
            except Exception as e:
                return f"error: failed to read clipboard: {e}"

            if not corrected_text:
                return "ignored: clipboard is empty"

            # Ignore no-op corrections: clipboard identical to what we produced teaches nothing
            if corrected_text == self.last_dictation["refined"]:
                return "ignored: clipboard matches previous dictation (nothing to learn)"

            record = {
                "raw": self.last_dictation["raw"],
                "refined": self.last_dictation["refined"],
                "corrected": corrected_text,
            }
            history_path = Path(self.config.history_path)
            try:
                with open(history_path, "a", encoding="utf-8") as f:
                    f.write(json.dumps(record, ensure_ascii=False) + "\n")
            except Exception as e:
                logger.error("Failed to write history: %s", e)

            logger.info("Correction captured: '%s'", corrected_text)
            self.last_dictation = None
            self.correction_count += 1

            if self.correction_count >= 10:
                with self._learning_lock:
                    if not self._is_learning_running:
                        self._is_learning_running = True
                        threading.Thread(target=self._run_learning_cycle, daemon=True).start()
            return f"ok: correction captured (count: {self.correction_count})"

    def _run_learning_cycle(self) -> None:
        try:
            history_path = Path(self.config.history_path)
            if not history_path.exists():
                return
            lines = [line.strip() for line in history_path.read_text(encoding="utf-8").splitlines() if line.strip()]
            if not lines:
                return
            history_records = [json.loads(line) for line in lines]

            vocab_path = Path(self.config.vocab_path)
            vocab_list = []
            if vocab_path.exists():
                try:
                    vocab_list = json.loads(vocab_path.read_text(encoding="utf-8"))
                    if not isinstance(vocab_list, list):
                        vocab_list = []
                except Exception:
                    vocab_list = []

            memory_path = Path(self.config.memory_path)
            current_memory = memory_path.read_text(encoding="utf-8") if memory_path.exists() else ""

            system_prompt = (
                "Ты — агент самообучения и сжатия памяти для системы диктовки разработчика (Agentic Core Memory).\n"
                "Твоя задача — проанализировать историю ошибок и ручных исправлений пользователя, "
                "добавить новые термины в словарь и обновить Core Memory.\n"
                "Отвечай СТРОГО в формате валидного JSON со следующими полями:\n"
                "{\n"
                '  "new_vocab": ["термин1", "термин2"],\n'
                '  "new_memory": "краткие правила стиля, опечатки и предпочтения..."\n'
                "}\n"
                "Правила:\n"
                "1. 'new_vocab': массив строк. Добавь до 3 новых IT-терминов/библиотек из исправлений к текущему словарю. Максимум 50 элементов.\n"
                "2. 'new_memory': Markdown-строка правил стиля. Опиши специфику форматирования и частые опечатки. Длина СТРОГО до 500 символов."
            )
            user_prompt = (
                f"Текущая память (Core Memory):\n{current_memory}\n\n"
                f"Текущий словарь терминов:\n{json.dumps(vocab_list, ensure_ascii=False)}\n\n"
                f"История исправлений пользователя:\n{json.dumps(history_records, ensure_ascii=False)}\n\n"
                "Сформулируй обновлённую память и словарь в JSON."
            )

            headers = {"Authorization": f"Bearer {self.config.api_key}"}
            chat_url = f"{self.config.base_url.rstrip('/')}/chat/completions"

            chat_payload = {
                "model": self.config.refinement_model,
                "temperature": 0.2,
                "response_format": {"type": "json_object"},
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
            }

            with httpx.Client(headers=headers, timeout=30.0) as client:
                resp = client.post(chat_url, json=chat_payload)
                resp.raise_for_status()
                data = resp.json()
                content_str = data["choices"][0]["message"]["content"].strip()
                result_json = _extract_json_payload(content_str)

                new_vocab = result_json.get("new_vocab", vocab_list)
                new_memory = str(result_json.get("new_memory", current_memory)).strip()

                # Retry logic if new_memory exceeds 500 chars
                if len(new_memory) > 500:
                    retry_payload = {
                        "model": self.config.refinement_model,
                        "temperature": 0.1,
                        "response_format": {"type": "json_object"},
                        "messages": [
                            {"role": "system", "content": system_prompt},
                            {"role": "user", "content": user_prompt},
                            {"role": "assistant", "content": content_str},
                            {
                                "role": "user",
                                "content": f"Твой ответ в 'new_memory' слишком длинный ({len(new_memory)} символов). Строго сожми 'new_memory' до менее чем 500 символов, сохранив самую важную суть.",
                            },
                        ],
                    }
                    try:
                        retry_resp = client.post(chat_url, json=retry_payload)
                        retry_resp.raise_for_status()
                        retry_json = _extract_json_payload(retry_resp.json()["choices"][0]["message"]["content"].strip())
                        new_memory = str(retry_json.get("new_memory", new_memory)).strip()
                    except Exception as retry_err:
                        logger.warning("Learning Cycle Retry Warning: %s", retry_err)

                if len(new_memory) > 500:
                    new_memory = _truncate_word_boundary(new_memory, 500)

                if isinstance(new_vocab, list):
                    clean_vocab = [str(w).strip() for w in new_vocab if str(w).strip()]
                    if len(clean_vocab) > 50:
                        clean_vocab = clean_vocab[-50:]
                else:
                    clean_vocab = vocab_list

                # Save updated files atomically
                atomic_write_text(vocab_path, json.dumps(clean_vocab, ensure_ascii=False, indent=2))
                atomic_write_text(memory_path, new_memory)
                atomic_write_text(history_path, "")

                with self.lock:
                    self.correction_count = 0

                logger.info("Learning Cycle Success: Memory and vocabulary updated")
        except Exception as e:
            logger.error("Learning Cycle Error: %s", e, exc_info=True)
        finally:
            with self._learning_lock:
                self._is_learning_running = False

    def stop_service(self) -> None:
        self.recorder.stop()
        self.ipc_server.stop()
        self.stop_event.set()


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        stream=sys.stdout,
    )
    parser = argparse.ArgumentParser(description="Noctalia Dictation Headless Daemon & CLI")
    parser.add_argument(
        "command",
        nargs="?",
        choices=["toggle", "stop", "status", "capture-correction"],
        help="Command to send to running daemon",
    )
    parser.add_argument(
        "--follow",
        action="store_true",
        help="Follow real-time status event stream (used with status command)",
    )
    args = parser.parse_args()

    # CLI modes
    if args.command == "status" and args.follow:
        try:
            stream_ipc_events()
            sys.exit(0)
        except KeyboardInterrupt:
            sys.exit(0)
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)

    if args.command:
        try:
            resp = send_ipc_command(args.command)
            print(resp)
            sys.exit(0)
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)

    # Daemon mode
    service = DictationService()
    service.start()

    def handle_exit(signum, frame):
        service.stop_service()
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_exit)
    signal.signal(signal.SIGTERM, handle_exit)

    # Wait until stopped
    service.stop_event.wait()


if __name__ == "__main__":
    main()
