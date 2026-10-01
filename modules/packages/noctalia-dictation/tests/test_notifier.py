import sys
from pathlib import Path

# Add src to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from notifier import Notifier


def _make_notifier(monkeypatch, sent):
    """Notifier with stubbed notify-send; records command lines into `sent`."""

    class FakeProc:
        def __init__(self):
            self.returncode = 0

    monkeypatch.setattr("notifier.shutil.which", lambda _: "/usr/bin/notify-send")
    monkeypatch.setattr(
        "notifier.subprocess.run",
        lambda cmd, **kw: sent.append(tuple(cmd)) or FakeProc(),
    )
    return Notifier(dedupe_window=10.0)


def test_dedupe_suppresses_identical_notification(monkeypatch):
    sent: list = []
    n = _make_notifier(monkeypatch, sent)

    n.notify_correction_rejected()
    n.notify_correction_rejected()
    n.notify_correction_rejected()

    # Three identical notifications within the window -> only one notify-send
    assert len(sent) == 1


def test_different_notifications_are_not_suppressed(monkeypatch):
    sent: list = []
    n = _make_notifier(monkeypatch, sent)

    n.notify_correction_rejected()
    n.notify_correction_captured(2, 10)
    n.notify_learning_success()

    assert len(sent) == 3


def test_expired_window_allows_repeat(monkeypatch):
    import notifier as notifier_module

    sent: list = []
    n = _make_notifier(monkeypatch, sent)

    # Fake clock: start at 100s, advance past the dedupe window each call
    clock = {"t": 100.0}
    monkeypatch.setattr(notifier_module.time, "monotonic", lambda: clock["t"])

    n.notify_correction_rejected()
    clock["t"] += 20.0  # beyond dedupe_window=10
    n.notify_correction_rejected()

    assert len(sent) == 2
