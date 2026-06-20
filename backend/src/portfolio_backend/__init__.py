"""Portfolio backend — anticipated skeleton (Python / FastAPI / Pydantic v2).

This ecosystem is scaffolded now but intentionally contains no business logic in Lot 1: the public
site is fully static and ships without any Python runtime. The FastAPI application — private-area
API with token-based access (configurable validity, revocation) and a back-office — is implemented
in Lot 2. The contract with the frontend is the HTTP API (Pydantic v2 -> OpenAPI), never shared code.
"""

__all__: list[str] = []
