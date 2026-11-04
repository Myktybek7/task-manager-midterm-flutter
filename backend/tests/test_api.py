import pytest
from fastapi.testclient import TestClient

from backend.main import create_app


@pytest.fixture
def database_url(tmp_path):
    return f"sqlite:///{tmp_path / 'tasks.db'}"


@pytest.fixture
def client(database_url):
    with TestClient(create_app(database_url)) as client:
        yield client


def test_crud(client):
    assert client.get('/tasks').json() == []
    response = client.post('/tasks', json={'title': 'Study Flutter'})
    assert response.status_code == 201
    task = response.json()
    assert task == {'id': task['id'], 'title': 'Study Flutter', 'isCompleted': False}
    assert isinstance(task['id'], int)
    url = f"/tasks/{task['id']}"
    assert client.get('/tasks').json() == [task]
    response = client.put(url, json={'isCompleted': True})
    assert response.status_code == 200
    assert response.json() == {**task, 'isCompleted': True}
    response = client.put(url, json={'title': 'Updated'})
    assert response.json() == {**task, 'title': 'Updated', 'isCompleted': True}
    assert client.put(url, json={}).json() == response.json()
    response = client.put(url, json={'title': 'Both', 'isCompleted': False})
    assert response.json() == {**task, 'title': 'Both', 'isCompleted': False}
    response = client.delete(url)
    assert response.status_code == 204
    assert response.content == b''
    assert client.get('/tasks').json() == []
    assert client.delete(url).status_code == 404


@pytest.mark.parametrize('method', ['put', 'delete'])
def test_missing_task(client, method):
    kwargs = {'json': {'title': 'Missing'}} if method == 'put' else {}
    assert getattr(client, method)('/tasks/999', **kwargs).status_code == 404


@pytest.mark.parametrize('payload', [{}, {'title': ''}, {'title': '   '},
    {'title': None}, {'title': 123}, {'title': 'Task', 'unknown': True}])
def test_invalid_create(client, payload):
    assert client.post('/tasks', json=payload).status_code == 422
    assert client.get('/tasks').json() == []


@pytest.mark.parametrize('payload', [{'title': ''}, {'title': '  '}, {'title': None},
    {'title': 42}, {'isCompleted': None}, {'isCompleted': 'true'},
    {'isCompleted': 1}, {'unknown': True}])
def test_invalid_update(client, payload):
    task = client.post('/tasks', json={'title': 'Original'}).json()
    assert client.put(f"/tasks/{task['id']}", json=payload).status_code == 422
    assert client.get('/tasks').json() == [task]


def test_invalid_path_and_json(client):
    assert client.put('/tasks/not-an-id', json={'title': 'Task'}).status_code == 422
    assert client.delete('/tasks/not-an-id').status_code == 422
    assert client.post('/tasks', content='{', headers={'Content-Type': 'application/json'}).status_code == 422


def test_persistence_across_app_restarts(database_url):
    with TestClient(create_app(database_url)) as first:
        task = first.post('/tasks', json={'title': 'Persistent'}).json()
        first.put(f"/tasks/{task['id']}", json={'isCompleted': True})
    with TestClient(create_app(database_url)) as second:
        assert second.get('/tasks').json() == [{**task, 'isCompleted': True}]
        assert second.delete(f"/tasks/{task['id']}").status_code == 204
    with TestClient(create_app(database_url)) as third:
        assert third.get('/tasks').json() == []


def test_cors(client):
    response = client.options('/tasks', headers={
        'Origin': 'http://localhost:54321',
        'Access-Control-Request-Method': 'PUT',
        'Access-Control-Request-Headers': 'content-type',
    })
    assert response.status_code == 200
    assert response.headers['access-control-allow-origin'] == '*'
