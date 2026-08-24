from typing import List, Optional

from pydantic import BaseModel, Field


class RawPost(BaseModel):
    source_id: str
    source_type: str = "post"
    content: str


class ExtractedActivity(BaseModel):
    activity_type: str = Field(
        ..., description="project, knowledge_share, achievement, volunteer, other"
    )
    title: str
    role: Optional[str] = None
    summary: str
    tools: List[str] = Field(default_factory=list)
    skills: List[str] = Field(default_factory=list)
    outcome: Optional[str] = None
    date: Optional[str] = None
    source_id: str


class CVSection(BaseModel):
    heading: str
    items: List[dict]  # Each item: title, bullet, evidence


class GeneratedCV(BaseModel):
    summary: str
    sections: List[CVSection]
