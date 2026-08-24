import hashlib


class InMemoryCache:
    def __init__(self):
        self._store = {}

    def get(self, key: str):
        return self._store.get(key)

    def set(self, key: str, value):
        self._store[key] = value

    def make_key(self, content: str, source_id: str) -> str:
        raw = f"{source_id}:{content}"
        return hashlib.sha256(raw.encode()).hexdigest()
