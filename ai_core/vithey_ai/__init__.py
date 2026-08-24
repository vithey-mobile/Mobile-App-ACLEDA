"""Vithey AI core package.

Public surface (import these from the rest of the app):
- VitheyAI          : main facade
- ExtractedActivity  : structured activity model
- GeneratedCV        : generated CV model
- RawPost            : raw post input model

Everything else in this package is internal and should not be imported
by the rest of the application.
"""

from .service import VitheyAI
from .schemas import ExtractedActivity, GeneratedCV, RawPost

__all__ = [
    "VitheyAI",
    "ExtractedActivity",
    "GeneratedCV",
    "RawPost",
]

__version__ = "0.1.0"
