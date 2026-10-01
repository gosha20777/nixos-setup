from typing import Literal, Optional
from pydantic import BaseModel, Field

DEFAULT_SYSTEM_PROMPT = """Ты — помощник по диктовке промптов и текста.
Твоя задача — преобразовать распознанный голос в чистый, грамотный и готовый к использованию текст:
1. Исправь оговорки, заикания, слова-паразиты («э-э», «ну типа», «короче»).
2. Расставь знаки препинания и заглавные буквы.
3. ЗАПРЕЩЕНО добавлять переносы строк (\\n) или списки, если пользователь явно не продиктовал их («новая строка», «абзац»). Весь текст должен идти сплошным монолитом.
4. Сохрани оригинальный язык (русский, английский или смешанный).
5. Точно и корректно форматируй технические термины, имена библиотек, флаги CLI и синтаксис кода (например, asyncio, flake.nix, git commit, Docker, Python).
6. Не добавляй никаких пояснений, комментариев, мета-текста или кавычек от себя. Возвращай ИСКЛЮЧИТЕЛЬНО очищенный текст."""


class DictationConfig(BaseModel):
    api_key: str = Field(description="Groq API key")
    base_url: str = Field(default="https://api.groq.com/openai/v1", description="Groq/OpenAI compatible base URL")
    stt_model: str = Field(default="whisper-large-v3-turbo", description="Speech to text model")
    refinement_model: str = Field(default="qwen/qwen3.8-27b", description="LLM model for prompt cleanup")
    system_prompt: str = Field(default=DEFAULT_SYSTEM_PROMPT, description="System prompt for LLM")
    silence_duration_seconds: float = Field(default=3.0, ge=0.5, le=10.0, description="Silence threshold for auto-stop")
    vad_aggressiveness: int = Field(default=2, ge=0, le=3, description="WebRTC VAD aggressiveness (0-3)")
    sample_rate: int = Field(default=16000, description="Audio sample rate in Hz")
    vocab_path: str = Field(default="", description="Path to vocabulary.json")
    memory_path: str = Field(default="", description="Path to memory.md")
    history_path: str = Field(default="", description="Path to history.jsonl")


class StateResponse(BaseModel):
    state: Literal["idle", "recording", "processing"] = Field(
        default="idle", description="Current daemon state"
    )
    error: Optional[str] = Field(default=None, description="Error message if any")
