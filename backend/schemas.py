from typing import Annotated

from pydantic import BaseModel, ConfigDict, StrictBool, StringConstraints, model_validator

Title = Annotated[str, StringConstraints(strict=True, strip_whitespace=True, min_length=1)]


class TaskCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    title: Title


class TaskUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    title: Title | None = None
    isCompleted: StrictBool | None = None

    @model_validator(mode="after")
    def reject_null_fields(self):
        for field in self.model_fields_set:
            if getattr(self, field) is None:
                raise ValueError(f"{field} cannot be null")
        return self


class TaskRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    title: str
    isCompleted: bool
