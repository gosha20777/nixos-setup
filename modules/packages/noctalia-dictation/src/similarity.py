import re

from difflib import SequenceMatcher

# Corrections that only touch punctuation/case must not be rejected: they are
# the most common real corrections. Normalization keeps letters/digits/space
# so "Привет мир." vs "привет, мир!" normalizes to the same string.
_WORD_RE = re.compile(r"[^\w\s]+", re.UNICODE)


def normalize(text: str) -> str:
    """Lowercase, strip punctuation, collapse whitespace."""
    cleaned = _WORD_RE.sub(" ", text.casefold())
    return " ".join(cleaned.split()).strip()


def correction_score(corrected: str, raw: str, refined: str) -> float:
    """Similarity of the corrected text to the dictation it should fix.

    Compares against both the refined text (LLM output) and the raw transcript
    (Whisper output) and takes the best match: a correction may target either
    stage. Returns 0.0..1.0; >= 0.5 means "looks like a real correction".
    """
    target = normalize(corrected)
    if not target:
        return 0.0
    return max(
        SequenceMatcher(a=target, b=normalize(raw)).ratio(),
        SequenceMatcher(a=target, b=normalize(refined)).ratio(),
    )
