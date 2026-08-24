from pydantic import ValidationError

from .deepseek_client import DeepSeekClient
from .errors import AIResponseValidationError
from .prompts import EXTRACTION_SYSTEM_PROMPT
from .schemas import ExtractedActivity


class ExtractionService:
    def __init__(self, client: DeepSeekClient):
        self.client = client

    def extract(
        self, content: str, source_id: str, source_type: str = "post"
    ) -> ExtractedActivity:
        user_prompt = f"Post content:\n{content}\n\nSource ID: {source_id}"
        data = self.client.ask_json(EXTRACTION_SYSTEM_PROMPT, user_prompt)
        data["source_id"] = source_id  # force correct source_id
        try:
            return ExtractedActivity(**data)
        except ValidationError as e:
            raise AIResponseValidationError(
                f"AI response failed schema validation: {e}"
            ) from e
