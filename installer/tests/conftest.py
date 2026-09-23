"""Pytest bootstrap: ensure the repository root is on sys.path so the
``installer`` package is importable when tests are run from the repo root."""

import sys
from pathlib import Path

REPO_ROOT = str(Path(__file__).resolve().parent.parent.parent)
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)
