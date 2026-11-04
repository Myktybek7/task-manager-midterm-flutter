"""SQLite configuration. The default database stays beside this module."""
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

DEFAULT_DATABASE_URL = f"sqlite:///{Path(__file__).resolve().parent / 'tasks.db'}"


class Base(DeclarativeBase):
    pass


def create_database(database_url: str):
    engine = create_engine(database_url, connect_args={"check_same_thread": False})
    return engine, sessionmaker(bind=engine, expire_on_commit=False)
