import io
import logging
import queue
import threading
import wave
from typing import Callable, Optional
import sounddevice as sd
import webrtcvad

logger = logging.getLogger("noctalia-dictation")

CHANNELS = 1
FRAME_DURATION_MS = 30  # webrtcvad accepts 10, 20, or 30 ms

class AudioRecorder:
    def __init__(
        self,
        sample_rate: int = 16000,
        silence_seconds: float = 1.5,
        vad_aggressiveness: int = 2,
        on_silence: Optional[Callable[[], None]] = None,
    ):
        self.sample_rate = sample_rate
        self.frame_size = int(self.sample_rate * FRAME_DURATION_MS / 1000)
        self.frame_bytes = self.frame_size * 2  # 16-bit mono = 2 bytes per sample
        self.silence_limit_frames = int((silence_seconds * 1000) / FRAME_DURATION_MS)

        self.vad = webrtcvad.Vad(vad_aggressiveness)
        self.on_silence = on_silence

        self._stream: Optional[sd.RawInputStream] = None
        self._frames: list[bytes] = []
        self._is_recording = False
        self._has_spoken = False
        self._silent_frames_count = 0
        self._silence_signaled = False
        self._event_queue: queue.Queue[str] = queue.Queue()
        self._worker_thread: Optional[threading.Thread] = None
        self._lock = threading.Lock()

    def start(self) -> None:
        with self._lock:
            if self._is_recording:
                return
            self._frames = []
            self._is_recording = True
            self._has_spoken = False
            self._silent_frames_count = 0
            self._silence_signaled = False

            # Worker thread processes events outside real-time audio callback
            self._worker_thread = threading.Thread(target=self._event_worker, daemon=True)
            self._worker_thread.start()

            self._stream = sd.RawInputStream(
                samplerate=self.sample_rate,
                channels=CHANNELS,
                dtype="int16",
                blocksize=self.frame_size,
                callback=self._audio_callback,
            )
            self._stream.start()

    def _audio_callback(self, indata, frames, time_info, status) -> None:
        if not self._is_recording:
            return

        data_bytes = bytes(indata)
        if len(data_bytes) != self.frame_bytes:
            return

        with self._lock:
            self._frames.append(data_bytes)
            is_speech = self.vad.is_speech(data_bytes, self.sample_rate)

            if is_speech:
                self._has_spoken = True
                self._silent_frames_count = 0
            elif self._has_spoken and not self._silence_signaled:
                self._silent_frames_count += 1
                if self._silent_frames_count >= self.silence_limit_frames:
                    self._silence_signaled = True
                    self._event_queue.put("silence")

    def _event_worker(self) -> None:
        while True:
            try:
                event = self._event_queue.get(timeout=0.1)
            except queue.Empty:
                with self._lock:
                    if not self._is_recording:
                        break
                continue

            if event == "stop":
                break
            elif event == "silence":
                if self.on_silence:
                    try:
                        self.on_silence()
                    except Exception as e:
                        logger.error("Error in on_silence callback: %s", e)

    def stop(self) -> bytes:
        with self._lock:
            if not self._is_recording:
                return b""
            self._is_recording = False
            self._event_queue.put("stop")
            if self._stream is not None:
                try:
                    self._stream.stop()
                    self._stream.close()
                except Exception as e:
                    logger.warning("Error stopping audio stream: %s", e)
                self._stream = None

            wav_buffer = io.BytesIO()
            with wave.open(wav_buffer, "wb") as wf:
                wf.setnchannels(CHANNELS)
                wf.setsampwidth(2)  # 16-bit
                wf.setframerate(self.sample_rate)
                wf.writeframes(b"".join(self._frames))

            return wav_buffer.getvalue()

    @property
    def is_recording(self) -> bool:
        with self._lock:
            return self._is_recording
