import io
import json
import logging
from pathlib import Path
import httpx
from config import DictationConfig

logger = logging.getLogger("noctalia-dictation")

def _build_whisper_prompt(vocab_path: str, base_prompt: str = "") -> str:
    """Build prompt for Whisper with optional base context and vocab terms, bounded at 400 chars."""
    vocab_words = []
    if vocab_path:
        try:
            path = Path(vocab_path)
            if path.exists():
                words = json.loads(path.read_text(encoding="utf-8"))
                if isinstance(words, list):
                    vocab_words = [w.strip() for w in words if isinstance(w, str) and w.strip()]
        except Exception as e:
            logger.warning("Failed to read vocabulary prompt from %s: %s", vocab_path, e)

    prefix = base_prompt.strip() if base_prompt else ""
    if not prefix and not vocab_words:
        return ""

    if not prefix:
        res = []
        cur_len = 0
        for w in vocab_words:
            add_len = len(w) + (2 if res else 0)
            if cur_len + add_len > 400:
                break
            res.append(w)
            cur_len += add_len
        return ", ".join(res)

    res = [prefix]
    cur_len = len(prefix)
    sep = " " if prefix.endswith((".", "!", "?", ":", ";")) else ", "
    first = True
    for w in vocab_words:
        add_len = len(w) + (len(sep) if first else 2)
        if cur_len + add_len > 400:
            break
        res.append(w)
        cur_len += add_len
        first = False

    if len(res) == 1:
        return res[0]
    return res[0] + sep + ", ".join(res[1:])

def _read_memory_context(memory_path: str) -> str:
    """Read core memory rules to append to system prompt."""
    if not memory_path:
        return ""
    try:
        path = Path(memory_path)
        if not path.exists():
            return ""
        return path.read_text(encoding="utf-8").strip()
    except Exception as e:
        logger.warning("Failed to read core memory context from %s: %s", memory_path, e)
        return ""

def transcribe_and_refine_full(wav_bytes: bytes, config: DictationConfig) -> tuple[str, str]:
    """Send audio to Groq Whisper and refine with configured LLM.

    Returns:
        tuple of (refined_text, raw_text).
    """
    headers = {"Authorization": f"Bearer {config.api_key}"}

    with httpx.Client(headers=headers, timeout=30.0) as client:
        # 1. Speech-to-Text with prompt biasing
        files = {"file": ("audio.wav", io.BytesIO(wav_bytes), "audio/wav")}
        data = {
            "model": config.stt_model,
            "response_format": "text",
            "temperature": "0.0",
        }
        if config.stt_language:
            data["language"] = config.stt_language

        whisper_prompt = _build_whisper_prompt(config.vocab_path, config.stt_prompt)
        if whisper_prompt:
            data["prompt"] = whisper_prompt

        stt_url = f"{config.base_url.rstrip('/')}/audio/transcriptions"
        resp = client.post(stt_url, files=files, data=data)
        resp.raise_for_status()
        raw_text = resp.text.strip()

        if not raw_text:
            return "", ""

        # 2. Refine text via LLM with core memory context
        system_content = config.system_prompt
        memory_context = _read_memory_context(config.memory_path)
        if memory_context:
            system_content += f"\n\nПользовательские предпочтения и память (Core Memory):\n{memory_context}"

        # Wrap raw transcript inside clear XML boundaries and explicit instruction
        # to prevent conversational hijacking (e.g. model answering prompts instead of transcribing)
        refinement_user_prompt = (
            "Ниже приведен сырой распознанный голос пользователя. Твоя единственная задача — "
            "очистить его согласно правилам (исправить заикания/оговорки, термины, пунктуацию). "
            "Верни текст в одну строку.\n\n"
            f"<raw_transcript>\n{raw_text}\n</raw_transcript>"
        )

        chat_payload = {
            "model": config.refinement_model,
            "temperature": 0.2,
            "messages": [
                {"role": "system", "content": system_content},
                {"role": "user", "content": refinement_user_prompt},
            ],
        }
        chat_url = f"{config.base_url.rstrip('/')}/chat/completions"
        try:
            chat_resp = client.post(chat_url, json=chat_payload)
            chat_resp.raise_for_status()
            result = chat_resp.json()
            refined_text = result["choices"][0]["message"]["content"].strip()
            # Strip optional wrapping tags if LLM echoed them
            if refined_text.startswith("<raw_transcript>") and refined_text.endswith("</raw_transcript>"):
                refined_text = refined_text[len("<raw_transcript>"):-len("</raw_transcript>")].strip()
            return (refined_text or raw_text), raw_text
        except Exception as e:
            # Fallback to raw transcript if LLM refinement fails
            logger.error("LLM refinement failed, falling back to raw transcript: %s", e)
            return raw_text, raw_text

def transcribe_and_refine(wav_bytes: bytes, config: DictationConfig) -> str:
    """Send audio to Groq Whisper and refine with configured LLM, returning refined string."""
    refined_text, _ = transcribe_and_refine_full(wav_bytes, config)
    return refined_text
