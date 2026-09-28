"""CLI entry point for limine-enrich post-processor."""

import os
import sys

from parser import process_config
from profile_reader import get_profile_info


def main() -> None:
    cfg_paths = [
        "/boot/limine/limine.conf",
        "/efi/limine/limine.conf",
        "/boot/efi/limine/limine.conf",
    ]
    cfg_path = None
    for p in cfg_paths:
        if os.path.exists(p):
            cfg_path = p
            break

    if not cfg_path:
        sys.exit(0)

    try:
        with open(cfg_path, "r", encoding="utf-8") as f:
            content = f.read()

        new_content = process_config(content, get_profile_info)

        with open(cfg_path, "w", encoding="utf-8") as f:
            f.write(new_content)
    except Exception as e:
        print(f"warning: limine post-processing failed: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
