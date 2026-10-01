import logging
import shutil
import subprocess
import threading
import time

logger = logging.getLogger("noctalia-dictation")


class Notifier:
    """Sends desktop notifications via notify-send.

    Suppresses a notification identical to the previous one arriving within
    the dedupe window — guards against double-firing on race-y UI flows.
    Thread-safe: recording/correction events arrive on IPC threads, learning
    cycle results on their own worker thread.
    """

    def __init__(self, dedupe_window: float = 2.0):
        self._dedupe_window = dedupe_window
        self._last: tuple[tuple[str, str], float] = (("", ""), 0.0)
        self._lock = threading.Lock()

    def _send(
        self,
        summary: str,
        body: str,
        *,
        transient: bool = False,
        urgency: str = "normal",
        expire_ms: int | None = None,
    ) -> None:
        """Send one notification; degrade to log if notify-send is absent.

        transient=True makes the bubble auto-dismiss (toast) — used for
        high-rate events like "recording started" that must not pile up in a
        notification center. Non-transient notifications (learning cycle
        results) persist.
        """
        with self._lock:
            now = time.monotonic()
            key = (summary, body)
            if key == self._last[0] and now - self._last[1] < self._dedupe_window:
                return
            self._last = (key, now)

        if not shutil.which("notify-send"):
            logger.warning("notify-send not found in PATH; notification dropped: %s", summary)
            return

        cmd = ["notify-send", "--app-name", "noctalia-dictation", "--urgency", urgency, summary, body]
        if transient:
            cmd += ["--transient"]
        if expire_ms is not None:
            cmd += ["--expire-time", str(expire_ms)]

        try:
            subprocess.run(cmd, check=True, timeout=3.0)
        except Exception as e:
            logger.warning("Failed to send notification '%s': %s", summary, e)

    def notify_correction_captured(self, count: int, threshold: int) -> None:
        self._send("Диктовка", f"Правка сохранена ({count}/{threshold})", transient=True, expire_ms=2500)

    def notify_correction_rejected(self) -> None:
        self._send(
            "Диктовка",
            "Выделение не похоже на правку последней диктовки — не сохранено",
            transient=True,
            expire_ms=2500,
        )

    def notify_learning_success(self) -> None:
        self._send("Диктовка", "Цикл самообучения пройден: словарь и память обновлены")

    def notify_learning_error(self, message: str) -> None:
        self._send("Диктовка", f"Ошибка цикла самообучения: {message}", urgency="critical")
