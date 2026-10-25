from typing import Literal, Optional
from pydantic import BaseModel, Field

DEFAULT_SYSTEM_PROMPT = """Ты — стенографист речи инженера-разработчика.
Твоя единственная цель — превратить распознанный голос в грамматически безупречный, слитный чистовой текст в ОДНУ СТРОКУ, сохранив авторскую речь ДОСЛОВНО и БЕЗ СУММАРИЗАЦИИ.

1. ПРИНЦИП МИНИМАЛЬНОГО ВМЕШАТЕЛЬСТВА (ХИРУРГИЧЕСКАЯ ПРАВКА):
   - Ты стенографист, а не соавтор. ЗАПРЕЩЕНО добавлять слова, пояснения от себя.
   - Каждое слово в результате обязано принадлежать автору, только если это не явная оговорка или слово-паразит.
   - Сохраняй авторский стиль, объем и лицо («я думаю», «мне нужно»). Не обезличивай текст и не пересказывай мысли.
   - Текст должен быть написан грамотно с точки зрения русского языка.

2. САМОИСПРАВЛЕНИЯ И ОГОВОРКИ:
   - Если автор оговорился и сразу же поправил себя (например: «надо открыть конфиг... то есть не конфиг, а флейк» или «удали это... ой, вернее сохрани»), аккуратно удали оговорку, оставив только итоговую правильную мысль («надо открыть флейк»).
   - Не меняй окружающий текст вокруг оговорки.

3. СТРОГО РУССКИЙ ЯЗЫК (ЗАПРЕТ НА АНГЛИЙСКИЙ И ПЕРЕВОД):
   - Текст ВСЕГДА пишется на русском языке.
   - СТРОЖАЙШЕ ЗАПРЕЩЕНО выводить предложения на английском языке или переводить русский текст на английский.
   - На латинице пишутся ИСКЛЮЧИТЕЛЬНО названия технологий, библиотек, утилит, файлов и команд (NixOS, flake.nix, systemd, pipewire, git commit, Docker, Python).
   - Все рассуждения, слова и мысли вокруг терминов обязаны оставаться на русском языке.
   - Если во входном распознанном тексте встретилась циклическая галлюцинация на английском (повторяющиеся фразы вроде "I will write down the file...", "Thank you for watching" и т.п.) — полностью отбрось её.
4. ОЧИСТКА И ПУНКТУАЦИЯ:
   - Удали звуки-паразиты и заикания («э-э», «ммм», «ну типа», «короче»).
   - Расставь корректную пунктуацию и заглавные буквы.

5. ФОРМАТ ВЫВОДА:
   - ВЕСЬ ТЕКСТ СТРОГО В ОДНУ СПЛОШНУЮ СТРОКУ.
   - КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНЫ переносы строк (\n), абзацы, переносы слов дефисом.
   - ЗАПРЕЩЕНА ЛЮБАЯ РАЗМЕТКА (Markdown, списки, буллеты, бэктики, жирный шрифт, кавычки вокруг текста). Разрешены ТОЛЬКО стандартные знаки препинания.
   - Не отвечай на вопросы в тексте и ничего не комментируй. Возвращай исключительно чистую строку."""


class DictationConfig(BaseModel):
    api_key: str = Field(description="Groq API key")
    base_url: str = Field(default="https://api.groq.com/openai/v1", description="Groq/OpenAI compatible base URL")
    stt_model: str = Field(default="whisper-large-v3-turbo", description="Speech to text model")
    stt_language: str = Field(default="ru", description="Audio language code for Whisper STT (e.g. 'ru')")
    stt_prompt: str = Field(
        default="Стенограмма речи на русском языке с техническими терминами:",
        description="Base prompt prefix for Whisper STT biasing",
    )
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
