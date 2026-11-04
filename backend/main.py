from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Response, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from sqlalchemy.orm import Session

from .database import Base, DEFAULT_DATABASE_URL, create_database
from .models import Task
from .schemas import TaskCreate, TaskRead, TaskUpdate


def create_app(database_url: str = DEFAULT_DATABASE_URL) -> FastAPI:
    engine, session_factory = create_database(database_url)

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        Base.metadata.create_all(engine)
        try:
            yield
        finally:
            engine.dispose()

    app = FastAPI(title="Task Manager API", lifespan=lifespan)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["*"],
    )

    def get_session():
        with session_factory() as session:
            yield session

    SessionDependency = Annotated[Session, Depends(get_session)]

    def find_task(task_id: int, session: Session) -> Task:
        task = session.get(Task, task_id)
        if task is None:
            raise HTTPException(status_code=404, detail="Task not found")
        return task

    @app.get("/tasks", response_model=list[TaskRead])
    def list_tasks(session: SessionDependency):
        return session.scalars(select(Task).order_by(Task.id)).all()

    @app.post("/tasks", response_model=TaskRead, status_code=status.HTTP_201_CREATED)
    def create_task(payload: TaskCreate, session: SessionDependency):
        task = Task(title=payload.title, isCompleted=False)
        session.add(task)
        session.commit()
        session.refresh(task)
        return task

    @app.put("/tasks/{id}", response_model=TaskRead)
    def update_task(id: int, payload: TaskUpdate, session: SessionDependency):
        task = find_task(id, session)
        for field, value in payload.model_dump(exclude_unset=True).items():
            setattr(task, field, value)
        session.commit()
        session.refresh(task)
        return task

    @app.delete("/tasks/{id}", status_code=status.HTTP_204_NO_CONTENT)
    def delete_task(id: int, session: SessionDependency):
        task = find_task(id, session)
        session.delete(task)
        session.commit()
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    return app


app = create_app()
