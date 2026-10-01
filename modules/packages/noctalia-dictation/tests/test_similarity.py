import sys
from pathlib import Path

# Add src to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from similarity import correction_score, normalize


def test_normalize_strips_punctuation_and_case():
    assert normalize("Привет, мир!") == "привет мир"
    assert normalize("  Flake.nix   —  это  \n файл ") == "flake nix это файл"
    # Punctuation-only change normalizes to identical text
    assert normalize("Напиши функцию на Python.") == normalize("напиши функцию на python")


def test_score_accepts_small_word_fix():
    # Fixed one misrecognized word in a sentence
    raw = "напиши функцию на питоне"
    refined = "Напиши функцию на Питоне."
    corrected = "Напиши функцию на Python."
    assert correction_score(corrected, raw, refined) >= 0.5


def test_score_accepts_punctuation_only_correction():
    raw = "напиши функцию на python"
    refined = "Напиши функцию на Python."
    corrected = "напиши функцию на python"
    assert correction_score(corrected, raw, refined) >= 0.5


def test_score_accepts_correction_of_raw_transcript():
    # Correction targets what Whisper misheard, closer to raw than to refined
    raw = "попробуй journalctl и посмотри логи"
    refined = "Попробуй journalctl и посмотри логи."
    corrected = "попробуй journalctl --user и посмотри логи"
    assert correction_score(corrected, raw, refined) >= 0.5


def test_score_rejects_unrelated_text():
    raw = "напиши функцию на python"
    refined = "Напиши функцию на Python."
    corrected = "SELECT * FROM users WHERE id = 42;"
    assert correction_score(corrected, raw, refined) < 0.5


def test_score_rejects_fully_different_sentence():
    raw = "давай добавим кеширование в этот модуль"
    refined = "Давай добавим кеширование в этот модуль."
    corrected = "Погода сегодня отличная, пойдем гулять в парк"
    assert correction_score(corrected, raw, refined) < 0.5


def test_score_empty_selection_is_zero():
    assert correction_score("", "raw text", "refined text") == 0.0
    assert correction_score("   \n  ", "raw", "refined") == 0.0
