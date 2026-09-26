import sys
from pathlib import Path
import httpx

# Add src to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from backend import transcribe_and_refine
from models import DictationConfig


def test_transcribe_and_refine_success(monkeypatch):
    config = DictationConfig(api_key="gsk_mock_key")

    def mock_handler(request: httpx.Request):
        url = str(request.url)
        if url.endswith("/audio/transcriptions"):
            return httpx.Response(200, text="напиши функцию на питоне")
        elif url.endswith("/chat/completions"):
            return httpx.Response(
                200,
                json={
                    "choices": [
                        {
                            "message": {
                                "content": "Напиши функцию на Python."
                            }
                        }
                    ]
                },
            )
        return httpx.Response(404)

    mock_client = httpx.Client(transport=httpx.MockTransport(mock_handler))
    monkeypatch.setattr(httpx, "Client", lambda **kwargs: mock_client)

    dummy_wav = b"RIFF" + b"\x00" * 100
    result = transcribe_and_refine(dummy_wav, config)
    assert result == "Напиши функцию на Python."


def test_transcribe_and_refine_empty_audio(monkeypatch):
    config = DictationConfig(api_key="gsk_mock_key")

    def mock_handler(request: httpx.Request):
        return httpx.Response(200, text="")

    mock_client = httpx.Client(transport=httpx.MockTransport(mock_handler))
    monkeypatch.setattr(httpx, "Client", lambda **kwargs: mock_client)

    dummy_wav = b"RIFF" + b"\x00" * 100
    result = transcribe_and_refine(dummy_wav, config)
    assert result == ""


def test_transcribe_and_refine_llm_failure_fallback(monkeypatch):
    config = DictationConfig(api_key="gsk_mock_key")

    def mock_handler(request: httpx.Request):
        url = str(request.url)
        if url.endswith("/audio/transcriptions"):
            return httpx.Response(200, text="сырой текст без обработки")
        elif url.endswith("/chat/completions"):
            return httpx.Response(500, text="Internal Server Error")
        return httpx.Response(404)

    mock_client = httpx.Client(transport=httpx.MockTransport(mock_handler))
    monkeypatch.setattr(httpx, "Client", lambda **kwargs: mock_client)

    dummy_wav = b"RIFF" + b"\x00" * 100
    # Should fallback to raw transcript if LLM refinement fails
    result = transcribe_and_refine(dummy_wav, config)
    assert result == "сырой текст без обработки"
