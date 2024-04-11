from ib_insync import IB
import pytest

@pytest.mark.asyncio
async def test_ib_connection():
    attempts = 0
    ib = IB()
    while not ib.isConnected():
        if attempts >= 3:
            raise Exception("Failed to connect to IBKR after 3 attempts")
        try:
            await ib.connectAsync('localhost', 8888, clientId=0 )
        except Exception:
            pass
        attempts += 1

    ib.disconnect()

