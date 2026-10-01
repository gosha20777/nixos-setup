import json
import os
from pathlib import Path
import yaml
from models import DictationConfig

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

    base_dir = config_path.parent
    base_dir.mkdir(parents=True, exist_ok=True)

    vocab_file = base_dir / "vocabulary.json"
    if not vocab_file.exists() or vocab_file.read_text(encoding="utf-8").strip() in ("", "[]"):
        vocab_file.write_text(json.dumps(DEFAULT_VOCABULARY, ensure_ascii=False, indent=2), encoding="utf-8")

    memory_file = base_dir / "memory.md"
    if not memory_file.exists() or not memory_file.read_text(encoding="utf-8").strip():
        memory_file.write_text(DEFAULT_MEMORY, encoding="utf-8")
    history_file = base_dir / "history.jsonl"
    if not history_file.exists():
        history_file.write_text("", encoding="utf-8")

    raw_data.setdefault("vocab_path", str(vocab_file))
    raw_data.setdefault("memory_path", str(memory_file))
    raw_data.setdefault("history_path", str(history_file))

    return DictationConfig(**raw_data)
