import os

from dotenv import load_dotenv

load_dotenv()


class Config:
    DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")
    DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
    DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-chat")
    TEMPERATURE = 0.2
    MAX_TOKENS = 3000
    TIMEOUT_SECONDS = 30
