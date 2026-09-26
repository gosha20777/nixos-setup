import argparse
import signal
import sys
import threading
from typing import Optional

from audio import AudioRecorder
import backend
from config import load_config
import injector
from ipc import IPCServer, send_ipc_command, stream_ipc_events
from models import StateResponse


class DictationService:
    def __init__(self):
        self.config = load_config()
        self.current_state = StateResponse(state="idle")
        self.lock = threading.RLock()
        self.stop_event = threading.Event()

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
        print(
            f"noctalia-dictation daemon started. Models: {self.config.stt_model} + {self.config.refinement_model}",
            flush=True,
        )

    def handle_ipc_command(self, cmd: str) -> str:
        cmd = cmd.strip().lower()
        if cmd == "toggle":
            self.toggle()
            return f"ok: toggled, current state is {self.current_state.state}"
        elif cmd == "stop":
            self.stop_recording()
            return "ok: stopped"
        return f"error: unknown command '{cmd}'"

    def _on_silence_detected(self) -> None:
        with self.lock:
            if self.current_state.state == "recording":
                print("[dictation] Silence detected, finishing recording...", flush=True)
                self._stop_and_process()

    def toggle(self) -> None:
        with self.lock:
            state = self.current_state.state
            if state == "idle":
                self._start_recording()
            elif state == "recording":
                self._stop_and_process()
            elif state == "processing":
                print("[dictation] Already processing previous request...", flush=True)

    def stop_recording(self) -> None:
        with self.lock:
            if self.current_state.state == "recording":
                self._stop_and_process()

    def _start_recording(self) -> None:
        self._set_state("recording")
        print("[dictation] Recording started...", flush=True)
        self.recorder.start()

    def _stop_and_process(self) -> None:
        self._set_state("processing")
        wav_bytes = self.recorder.stop()

        # Minimum audio length check (~0.4s)
        min_bytes = int(self.config.sample_rate * 0.4 * 2)
        if len(wav_bytes) < min_bytes:
            print("[dictation] Audio too short, cancelled.", flush=True)
            self._set_state("idle")
            return

        print(f"[dictation] Processing {len(wav_bytes)} bytes audio via Groq...", flush=True)
        threading.Thread(target=self._process_worker, args=(wav_bytes,), daemon=True).start()

    def _process_worker(self, wav_bytes: bytes) -> None:
        try:
            refined_text = backend.transcribe_and_refine(wav_bytes, self.config)
            if refined_text:
                print(f"[dictation] Result: {refined_text}", flush=True)
                injector.inject_text(refined_text)
            else:
                print("[dictation] No speech recognized.", flush=True)
            self._set_state("idle")
        except Exception as e:
            err_msg = str(e)
            print(f"[dictation] Error processing speech: {err_msg}", file=sys.stderr, flush=True)
            self._set_state("idle", error=err_msg)

    def stop_service(self) -> None:
        self.recorder.stop()
        self.ipc_server.stop()
        self.stop_event.set()


def main():
    parser = argparse.ArgumentParser(description="Noctalia Dictation Headless Daemon & CLI")
    parser.add_argument(
        "command",
        nargs="?",
        choices=["toggle", "stop", "status"],
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
