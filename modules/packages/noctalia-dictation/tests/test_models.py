import pytest
from pydantic import ValidationError
import sys
from pathlib import Path

# Add src to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from models import DictationConfig, StateResponse


def test_state_response_serialization():
    idle_state = StateResponse(state="idle")
    json_str = idle_state.model_dump_json()
    assert '"state":"idle"' in json_str

    rec_state = StateResponse(state="recording")
    assert rec_state.state == "recording"
    assert rec_state.error is None

    proc_state = StateResponse(state="processing", error="something failed")
    assert proc_state.state == "processing"
    assert proc_state.error == "something failed"


def test_state_response_invalid_state():
    with pytest.raises(ValidationError):
        StateResponse(state="unknown_state")  # type: ignore


def test_dictation_config_defaults():
    config = DictationConfig(api_key="gsk_test123")
    assert config.api_key == "gsk_test123"
    assert config.base_url == "https://api.groq.com/openai/v1"
    assert config.stt_model == "whisper-large-v3-turbo"
    assert config.refinement_model == "qwen/qwen3.8-27b"
    assert config.silence_duration_seconds == 1.5
    assert config.vad_aggressiveness == 2
    assert config.sample_rate == 16000
    assert "Ты — помощник" in config.system_prompt


def test_dictation_config_custom_values():
    config = DictationConfig(
        api_key="gsk_custom",
        base_url="https://custom.endpoint/v1",
        stt_model="whisper-custom",
        refinement_model="llama-custom",
        silence_duration_seconds=2.5,
        vad_aggressiveness=3,
        system_prompt="Custom prompt",
    )
    assert config.api_key == "gsk_custom"
    assert config.base_url == "https://custom.endpoint/v1"
    assert config.silence_duration_seconds == 2.5
    assert config.vad_aggressiveness == 3
    assert config.system_prompt == "Custom prompt"


def test_dictation_config_invalid():
    with pytest.raises(ValidationError):
        # Missing required api_key
        DictationConfig()  # type: ignore
