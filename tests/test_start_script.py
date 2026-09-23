"""Regression tests for the container start scripts.

Covers https://github.com/extrange/ibkr-docker/issues/155.

IB's installer records the JRE that it unpacked for its own use in
``.install4j/inst_jre.cfg``. That extraction directory (``<installer>.<pid>.dir``)
is thrown away as soon as the installation finishes, so at runtime IBC finds a
cfg pointing at a directory that does not exist and fails with "Can't find
suitable Java installation" unless start.sh tells it where the JRE bundled with
the Gateway actually lives.

The tests run the real start.sh with the IBC launcher swapped for a stub, so the
arguments start.sh forwards are the ones under test.
"""

import os
import shutil
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_START_SCRIPT = REPO_ROOT / "image-files" / "start.sh"
CHANNEL_START_SCRIPTS = [
    REPO_ROOT / "stable" / "image-files" / "start.sh",
    REPO_ROOT / "latest" / "image-files" / "start.sh",
]

# IB Gateway 10.50.x installs into ~/Jts/ibgateway/1050
GATEWAY_MAJOR_VERSION = "1050"
IBCSTART_PATH_IN_SCRIPT = "/opt/ibc/scripts/ibcstart.sh"


def _run_start_script(tmp_path, bundled_jre):
    """Run start.sh with a stubbed IBC launcher and return its stdout.

    `bundled_jre` controls whether a JRE is present in the installed Gateway
    directory, which is what start.sh has to point IBC at.
    """
    home = tmp_path / "home"
    (home / "ibc").mkdir(parents=True)
    (home / "ibc" / "config.ini").write_text("[Logon]\nTradingMode=paper\n")

    gateway_dir = home / "Jts" / "ibgateway" / GATEWAY_MAJOR_VERSION
    (gateway_dir / "jars").mkdir(parents=True)
    if bundled_jre:
        jre_bin = gateway_dir / "jre" / "bin"
        jre_bin.mkdir(parents=True)
        java = jre_bin / "java"
        java.write_text("#!/bin/bash\necho '    java.runtime.version = 25.0.2.0.101'\n")
        java.chmod(0o755)

    stub = tmp_path / "ibcstart_stub.sh"
    stub.write_text('#!/bin/bash\nprintf "IBCSTART ARGS: %s\\n" "$@"\n')
    stub.chmod(0o755)

    script = tmp_path / "start.sh"
    contents = SOURCE_START_SCRIPT.read_text()
    assert IBCSTART_PATH_IN_SCRIPT in contents
    script.write_text(contents.replace(IBCSTART_PATH_IN_SCRIPT, str(stub)))
    shutil.copy(REPO_ROOT / "image-files" / "replace.sh", tmp_path / "replace.sh")

    # The bind mounts that exist inside the container (Xvnc, openbox, socat,
    # noVNC) are not available here; they are only ever started in the
    # background, so their absence must not stop start.sh reaching the launcher.
    env = dict(os.environ, HOME=str(home), IBC_TradingMode="paper")
    completed = subprocess.run(
        ["bash", str(script)],
        cwd=tmp_path,
        env=env,
        capture_output=True,
        text=True,
        timeout=60,
        check=False,
    )
    return completed


@pytest.mark.parametrize("bundled_jre", [True, False])
def test_java_path_points_at_bundled_jre(tmp_path, bundled_jre):
    completed = _run_start_script(tmp_path, bundled_jre)
    assert completed.returncode == 0, completed.stderr

    expected = (
        f"--java-path={tmp_path}/home/Jts/ibgateway/{GATEWAY_MAJOR_VERSION}/jre/bin"
    )
    if bundled_jre:
        assert expected in completed.stdout
    else:
        # Never hand IBC a path that does not exist: ibcstart.sh exits with
        # E_NO_JAVA when --java-path has no java executable.
        assert "--java-path" not in completed.stdout


def test_channel_start_scripts_are_up_to_date():
    """build.sh copies image-files/ into each channel, so they must not drift."""
    source = SOURCE_START_SCRIPT.read_bytes()
    for script in CHANNEL_START_SCRIPTS:
        assert script.read_bytes() == source, f"{script} is out of date, run ./build.sh"
