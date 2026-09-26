import io
import httpx
from config import DictationConfig


def transcribe_and_refine(wav_bytes: bytes, config: DictationConfig) -> str:
    """Send audio to Groq Whisper and refine with configured LLM."""
    headers = {"Authorization": f"Bearer {config.api_key}"}

    with httpx.Client(headers=headers, timeout=30.0) as client:
        # 1. Speech-to-Text
        files = {"file": ("audio.wav", io.BytesIO(wav_bytes), "audio/wav")}
        data = {
            "model": config.stt_model,
            "response_format": "text",
            "temperature": "0.0",
        }
        stt_url = f"{config.base_url.rstrip('/')}/audio/transcriptions"
        resp = client.post(stt_url, files=files, data=data)
        resp.raise_for_status()
        raw_text = resp.text.strip()

        if not raw_text:
            return ""

        # 2. Refine text via LLM
        chat_payload = {
            "model": config.refinement_model,
            "temperature": 0.2,
            "messages": [
                {"role": "system", "content": config.system_prompt},
                {"role": "user", "content": raw_text},
            ],
        }
        chat_url = f"{config.base_url.rstrip('/')}/chat/completions"
        try:
            chat_resp = client.post(chat_url, json=chat_payload)
            chat_resp.raise_for_status()
            result = chat_resp.json()
            refined_text = result["choices"][0]["message"]["content"].strip()
            return refined_text or raw_text
        except Exception:
            # Fallback to raw transcript if LLM refinement fails
            return raw_text
