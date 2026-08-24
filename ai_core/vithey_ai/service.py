from .config import Config
from .deepseek_client import DeepSeekClient
from .errors import EmptyInputError
from .extraction import ExtractionService
from .generation import CVGenerationService
from .schemas import ExtractedActivity, GeneratedCV, RawPost


class VitheyAI:
    """
    Main public entry point for the Vithey AI CV feature.
    Other devs should only use this class.
    """

    def __init__(self, api_key: str | None = None):
        config = Config()
        if api_key:
            config.DEEPSEEK_API_KEY = api_key

        if not config.DEEPSEEK_API_KEY:
            raise ValueError(
                "DEEPSEEK_API_KEY is required. Set it in .env or pass api_key."
            )

        self._client = DeepSeekClient(config)
        self._extractor = ExtractionService(self._client)
        self._generator = CVGenerationService(self._client)

    def extract_activity(
        self,
        content: str,
        source_id: str,
        source_type: str = "post",
    ) -> ExtractedActivity:
        return self._extractor.extract(content, source_id, source_type)

    def generate_cv(
        self,
        activities: list[ExtractedActivity],
        target_role: str = "",
        language: str = "en",
    ) -> GeneratedCV:
        return self._generator.generate(activities, target_role, language)

    def build_cv_from_raw_posts(
        self,
        posts: list[RawPost],
        target_role: str = "",
        language: str = "en",
    ) -> GeneratedCV:
        if not posts:
            raise EmptyInputError("No posts provided.")

        activities = []
        for post in posts:
            try:
                activity = self.extract_activity(
                    content=post.content,
                    source_id=post.source_id,
                    source_type=post.source_type,
                )
                activities.append(activity)
            except Exception:
                # Skip posts that fail extraction. Log later.
                continue

        if not activities:
            raise EmptyInputError("No valid activities could be extracted.")

        return self.generate_cv(activities, target_role, language)
