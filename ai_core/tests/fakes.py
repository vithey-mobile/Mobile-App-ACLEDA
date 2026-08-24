"""Shared test doubles for the Vithey AI core test suite."""


class MockDeepSeekClient:
    """Fake DeepSeek client returning canned JSON responses.

    Queue responses with ``responses=[...]`` (each entry is a dict returned
    by ``ask_json``) or force failures with ``errors=[...]``.
    """

    def __init__(self, responses=None, errors=None):
        self.responses = list(responses or [])
        self.errors = list(errors or [])
        self.calls = []

    def ask_json(self, system_prompt, user_prompt):
        self.calls.append((system_prompt, user_prompt))
        if self.errors:
            raise self.errors.pop(0)
        if not self.responses:
            raise AssertionError(
                "MockDeepSeekClient.ask_json called with no responses queued."
            )
        return self.responses.pop(0)
