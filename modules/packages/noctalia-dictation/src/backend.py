import io
import json
from pathlib import Path
import httpx
from config import DictationConfig


def _build_whisper_prompt(vocab_path: str) -> str:
    """Build comma-separated prompt for Whisper, smartly bounded at 400 chars."""
    if not vocab_path:
        return ""
    try:
        path = Path(vocab_path)
        if not path.exists():
            return ""
        words = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(words, list):
            return ""
        prompt_words = []
        current_len = 0
        for w in words:
            if not isinstance(w, str) or not w.strip():
                continue
            item = w.strip()
            add_len = len(item) + (2 if prompt_words else 0)
            if current_len + add_len > 400:
                break
            prompt_words.append(item)
            current_len += add_len
        return ", ".join(prompt_words)
    except Exception:
        return ""


def _read_memory_context(memory_path: str) -> str:
    """Read core memory rules to append to system prompt."""
    if not memory_path:
        return ""
    try:
        path = Path(memory_path)
        if not path.exists():
            return ""
        return path.read_text(encoding="utf-8").strip()
    except Exception:
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
        whisper_prompt = _build_whisper_prompt(config.vocab_path)
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

        chat_payload = {
            "model": config.refinement_model,
            "temperature": 0.2,
            "messages": [
                {"role": "system", "content": system_content},
                {"role": "user", "content": raw_text},
            ],
        }
        chat_url = f"{config.base_url.rstrip('/')}/chat/completions"
        try:
            chat_resp = client.post(chat_url, json=chat_payload)
            chat_resp.raise_for_status()
            result = chat_resp.json()
            refined_text = result["choices"][0]["message"]["content"].strip()
            return (refined_text or raw_text), raw_text
        except Exception:
            # Fallback to raw transcript if LLM refinement fails
            return raw_text, raw_text


def transcribe_and_refine(wav_bytes: bytes, config: DictationConfig) -> str:
    """Send audio to Groq Whisper and refine with configured LLM, returning refined string."""
    refined_text, _ = transcribe_and_refine_full(wav_bytes, config)
    return refined_text
