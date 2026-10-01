import json
import logging
import os
from pathlib import Path
import tempfile
import yaml
from models import DictationConfig

logger = logging.getLogger("noctalia-dictation")

DEFAULT_VOCABULARY = [
    "NixOS",
    "flake.nix",
    "nixpkgs",
    "niri",
    "Wayland",
    "Noctalia",
    "PyTorch",
    "CUDA",
    "OpenCV",
    "direnv",
    "uv",
    "ruff",
    "basedpyright",
    "Neovim",
    "Starship",
    "Kitty",
    "btrfs",
    "systemd",
    "journalctl",
    "git commit",
    "pull request",
    "asyncio",
    "Everforest",
]

DEFAULT_MEMORY = """# Developer Profile & Style Rules
- Стек: NixOS, Niri, Wayland, Python, PyTorch, CUDA, Neovim, Rust.
- Предпочитай технические термины на английском (например, feature, refactoring, pull request, build).
- Команды CLI и имена файлов пиши точно (flake.nix, git commit).
- Запрещены лишние вводные фразы и мета-комментарии."""

def atomic_write_text(path: Path, content: str) -> None:
    """Write content to path atomically via temporary file and replace."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False, encoding="utf-8") as tf:
        tf.write(content)
        temp_name = tf.name
    os.replace(temp_name, path)


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

    # Store writable dynamic data (vocab, memory, history) under ~/.config/noctalia-dictation
    # regardless of whether config.yaml is a symlink (e.g. to sops-nix secrets)
    data_dir = Path.home() / ".config" / "noctalia-dictation"
    data_dir.mkdir(parents=True, exist_ok=True)

    vocab_file = data_dir / "vocabulary.json"
    if not vocab_file.exists():
        atomic_write_text(vocab_file, json.dumps(DEFAULT_VOCABULARY, ensure_ascii=False, indent=2))
    else:
        try:
            content = vocab_file.read_text(encoding="utf-8").strip()
            if content in ("", "[]"):
                atomic_write_text(vocab_file, json.dumps(DEFAULT_VOCABULARY, ensure_ascii=False, indent=2))
        except Exception as e:
            logger.warning("Error reading vocab file %s: %s", vocab_file, e)

    memory_file = data_dir / "memory.md"
    if not memory_file.exists():
        atomic_write_text(memory_file, DEFAULT_MEMORY)
    else:
        try:
            content = memory_file.read_text(encoding="utf-8").strip()
            if not content:
                atomic_write_text(memory_file, DEFAULT_MEMORY)
        except Exception as e:
            logger.warning("Error reading memory file %s: %s", memory_file, e)

    history_file = data_dir / "history.jsonl"
    if not history_file.exists():
        atomic_write_text(history_file, "")

    raw_data.setdefault("vocab_path", str(vocab_file))
    raw_data.setdefault("memory_path", str(memory_file))
    raw_data.setdefault("history_path", str(history_file))

    return DictationConfig(**raw_data)
