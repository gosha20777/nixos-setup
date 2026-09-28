"""Pure text parser and regex replacer for Limine boot configuration."""

import re
from typing import Callable, Tuple

ResolverFn = Callable[[str], Tuple[str, str, str]]

ENTRY_PATTERN = re.compile(
    r"(/{1,3})(\+?)Generation\s+(\d+)\n(\s*protocol:\s*[^\n]+)\n\s*comment:\s*[^\n]+\n"
)


def process_config(content: str, resolver_fn: ResolverFn) -> str:
    """Enrich generation entries in limine.conf with date and note."""

    def enrich_entry(m: re.Match) -> str:
        prefix = m.group(1)  # "//" or "///"
        plus = m.group(2) or ""  # "+" if default entry
        gen = m.group(3)
        protocol = m.group(4)

        date_str, full_date, note_str = resolver_fn(gen)

        if date_str:
            title = f"{prefix}{plus}Generation {gen} ({date_str})"
            comment = f"comment: {note_str} · built on {full_date}"
        else:
            title = f"{prefix}{plus}Generation {gen}"
            comment = f"comment: {note_str}"

        return f"{title}\n{protocol}\n{comment}\n"

    return ENTRY_PATTERN.sub(enrich_entry, content)
