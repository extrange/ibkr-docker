import pytest
from ib_insync import IB

MAX_ATTEMPTS = 3


class IBKRConnectionError(RuntimeError):
    """Raised when the IB Gateway API does not accept a connection."""


@pytest.mark.asyncio
async def test_ib_connection():
    ib = IB()
    last_error: OSError | None = None
    for _ in range(MAX_ATTEMPTS):
        if ib.isConnected():
            break
        try:
            await ib.connectAsync("localhost", 8888, clientId=0)
        except OSError as exc:
            last_error = exc

    if not ib.isConnected():
        raise IBKRConnectionError(
            f"Failed to connect to IBKR after {MAX_ATTEMPTS} attempts"
        ) from last_error

    ib.disconnect()
