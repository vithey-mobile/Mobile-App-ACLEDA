class VitheyAIError(Exception):
    """Base exception for all Vithey AI errors."""


class AIClientError(VitheyAIError):
    """Raised when DeepSeek API call fails."""


class AIResponseValidationError(VitheyAIError):
    """Raised when AI returns invalid JSON or missing required fields."""


class EmptyInputError(VitheyAIError):
    """Raised when no activities provided for CV generation."""
