import json

from pydantic import ValidationError

from .deepseek_client import DeepSeekClient
from .errors import AIResponseValidationError, EmptyInputError
from .prompts import CV_GENERATION_SYSTEM_PROMPT
from .schemas import ExtractedActivity, GeneratedCV


class CVGenerationService:
    def __init__(self, client: DeepSeekClient):
        self.client = client

    def generate(
        self,
        activities: list[ExtractedActivity],
        target_role: str = "",
        language: str = "en",
    ) -> GeneratedCV:
        if not activities:
            raise EmptyInputError("No activities provided for CV generation.")

        activities_json = json.dumps(
            [a.model_dump() for a in activities], ensure_ascii=False
        )
        user_prompt = (
            f"User activities:\n{activities_json}\n\n"
            f"Target role: {target_role or 'Not specified'}\n"
            f"Language: {language}"
        )
        data = self.client.ask_json(CV_GENERATION_SYSTEM_PROMPT, user_prompt)
        try:
            return GeneratedCV(**data)
        except ValidationError as e:
            raise AIResponseValidationError(
                f"AI response failed schema validation: {e}"
            ) from e
