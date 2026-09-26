import os
from pathlib import Path
import yaml
from models import DictationConfig


def load_config() -> DictationConfig:
    config_path_str = os.environ.get("NOCTALIA_DICTATION_CONFIG")
    if config_path_str:
        config_path = Path(config_path_str)
    else:
        config_path = Path.home() / ".config" / "noctalia-dictation" / "config.yaml"

    if not config_path.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

    with open(config_path, "r", encoding="utf-8") as f:
        raw_data = yaml.safe_load(f)

    if not isinstance(raw_data, dict):
        raise ValueError(f"Invalid YAML config format at {config_path}")

    return DictationConfig(**raw_data)
