import json

from openai import OpenAI

from .config import Config
from .errors import AIClientError, AIResponseValidationError


class DeepSeekClient:
    def __init__(self, config: Config | None = None):
        self._config = config or Config()
        self.client = OpenAI(
            api_key=self._config.DEEPSEEK_API_KEY,
            base_url=self._config.DEEPSEEK_BASE_URL,
            timeout=self._config.TIMEOUT_SECONDS,
        )
        self.model = self._config.DEEPSEEK_MODEL
        self.temperature = self._config.TEMPERATURE

    def ask_json(self, system_prompt: str, user_prompt: str) -> dict:
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                response_format={"type": "json_object"},
                temperature=self.temperature,
                max_tokens=self._config.MAX_TOKENS,
            )
            content = response.choices[0].message.content
            if content is None:
                raise AIResponseValidationError("DeepSeek returned empty content.")
            return json.loads(content)
        except json.JSONDecodeError as e:
            raise AIResponseValidationError("DeepSeek returned invalid JSON.") from e
        except AIResponseValidationError:
            raise
        except Exception as e:
            raise AIClientError(f"DeepSeek API call failed: {e}") from e
