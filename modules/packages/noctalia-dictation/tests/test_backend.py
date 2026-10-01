import json
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


def test_build_whisper_prompt_smart_truncation(tmp_path):
    from backend import _build_whisper_prompt

    vocab_file = tmp_path / "vocab.json"
    # Create 50 words of 15 characters each
    words = [f"word_{i:03d}_longterm" for i in range(50)]
    vocab_file.write_text(json.dumps(words), encoding="utf-8")

    prompt = _build_whisper_prompt(str(vocab_file))
    assert len(prompt) <= 400
    # Ensure the last word is not truncated mid-word
    assert not prompt.endswith("longt")
    assert prompt.startswith("word_000_longterm")


def test_read_memory_context(tmp_path):
    from backend import _read_memory_context

    mem_file = tmp_path / "memory.md"
    mem_file.write_text("Пиши код аккуратно.\n", encoding="utf-8")

    mem = _read_memory_context(str(mem_file))
    assert mem == "Пиши код аккуратно."

    # Missing file returns empty
    assert _read_memory_context(str(tmp_path / "nonexistent.md")) == ""

def test_transcribe_and_refine_tag_stripping(monkeypatch):
    config = DictationConfig(api_key="gsk_mock_key")

    def mock_handler(request: httpx.Request):
        url = str(request.url)
        if url.endswith("/audio/transcriptions"):
            return httpx.Response(200, text="привет мир")
        elif url.endswith("/chat/completions"):
            return httpx.Response(
                200,
                json={
                    "choices": [
                        {
                            "message": {
                                "content": "<raw_transcript>Привет мир.</raw_transcript>"
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
    assert result == "Привет мир."


def test_extract_json_and_word_truncation():
    from main import _extract_json_payload, _truncate_word_boundary

    # 1. Plain JSON
    assert _extract_json_payload('{"new_vocab": ["abc"]}') == {"new_vocab": ["abc"]}

    # 2. Markdown fenced JSON
    fenced = "```json\n{\"new_vocab\": [\"abc\"], \"new_memory\": \"rules\"}\n```"
    assert _extract_json_payload(fenced) == {"new_vocab": ["abc"], "new_memory": "rules"}

    # 3. Word boundary truncation
    long_text = "слово1 слово2 слово3 слово4 слово5"
    truncated = _truncate_word_boundary(long_text, 20)
    assert len(truncated) <= 20
    assert not truncated.endswith("сло")  # Does not cut inside word
    assert truncated == "слово1 слово2 слово3"
