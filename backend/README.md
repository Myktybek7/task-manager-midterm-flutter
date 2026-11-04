# Task Manager backend

A local FastAPI API using SQLAlchemy, SQLite, and Pydantic. No authentication is required. All backend files, the virtual environment, and the database live inside `backend/`; Flutter code is unchanged.

## macOS setup and launch

Use Python 3.10 or newer. Run these commands **from the project root** (the directory containing `backend/` and `pubspec.yaml`):

```sh
python3 -m venv backend/.venv
source backend/.venv/bin/activate
python -m pip install -r backend/requirements.txt
python -m uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

Open http://127.0.0.1:8000/docs for interactive API documentation. Stop with Ctrl+C. Relaunch with the same uvicorn command; saved tasks remain in `backend/tasks.db`. The database path is absolute and derived from `database.py`, so changing the working directory cannot silently select another database. Tables are created automatically at startup. Do not delete `tasks.db` if you want to retain tasks.

`--host 0.0.0.0` allows local devices to connect. Use these base URLs for a Flutter HTTP client:

- macOS or iOS Simulator: `http://127.0.0.1:8000`
- Android Emulator: `http://10.0.2.2:8000`
- Physical phone: `http://<your-Mac-LAN-IP>:8000` on the same local network

The backend permits all CORS origins for local development, including Flutter web's varying localhost ports. CORS does not configure native mobile platform HTTP permissions. No mobile configuration is changed by this backend.

## API

Task JSON always has exactly `id` (integer), `title` (string), and `isCompleted` (boolean):

```json
{"id": 1, "title": "Study Flutter", "isCompleted": false}
```

| Method | Path | JSON request | Success response |
| --- | --- | --- | --- |
| GET | `/tasks` | None | 200, array of tasks ordered by ID; `[]` if empty |
| POST | `/tasks` | `{"title":"Study Flutter"}` | 201, created task with generated ID and `isCompleted: false` |
| PUT | `/tasks/{id}` | `{"title":"New title"}` and/or `{"isCompleted":true}` | 200, updated task |
| DELETE | `/tasks/{id}` | None | 204, empty body |

PUT updates only supplied fields; omitted fields are preserved. An empty object is a valid no-op update. Titles are trimmed and must contain at least one non-whitespace character. Nulls, wrong JSON types, and unknown request properties are rejected with HTTP 422. Completion must be a JSON boolean (`true` or `false`). Invalid path IDs and malformed JSON also return 422. Updating or deleting a nonexistent integer ID returns 404 with `{"detail":"Task not found"}`. Validation errors return FastAPI's standard `detail` array.

Example requests while the server is running:

```sh
curl -i -X POST http://127.0.0.1:8000/tasks \
  -H 'Content-Type: application/json' -d '{"title":"Study Flutter"}'
curl http://127.0.0.1:8000/tasks
curl -X PUT http://127.0.0.1:8000/tasks/1 \
  -H 'Content-Type: application/json' -d '{"isCompleted":true}'
curl -i -X DELETE http://127.0.0.1:8000/tasks/1
```

For Flutter, send `Content-Type: application/json` with POST and PUT, decode GET as a JSON list, and do not JSON-decode DELETE's empty response. BLoC can call these endpoints through an HTTP repository; no BLoC-specific server protocol is needed.

## Tests

From the project root, with the virtual environment activated:

```sh
python -m pytest -c backend/pytest.ini -q
```

Tests cover CRUD, partial updates, exact response keys, 404s, invalid requests, CORS, and persistence across independently created application instances with disposed database engines. They use temporary SQLite files and never touch `backend/tasks.db`.

## Files

- `main.py`: application factory, startup lifecycle, CORS, and endpoints.
- `database.py`: SQLite path, SQLAlchemy base, engine, and session factory.
- `models.py`: persisted task model.
- `schemas.py`: validated request and response models.
- `requirements.txt`: application and test dependencies.
- `tests/test_api.py`: automated API tests.

Implementation references: [FastAPI partial updates](https://fastapi.tiangolo.com/tutorial/body-updates/), [SQLAlchemy sessions](https://docs.sqlalchemy.org/en/20/orm/session_basics.html).
