#! /nix/var/nix/profiles/default/bin/nix-shell
#! nix-shell -i python3 -p python3Packages.requests
import argparse
import logging
import os
import subprocess
import tempfile
import time
from collections.abc import Mapping
from datetime import timedelta
from pathlib import Path
from typing import Callable

import requests

EXTRA_PATHS = "@@EXTRA_PATHS@@"
NIKS3_SERVER_URL = "@@NIKS3_SERVER_URL@@"
ACTIONS_ID_TOKEN_REQUEST_TOKEN = "@@ACTIONS_ID_TOKEN_REQUEST_TOKEN@@"
ACTIONS_ID_TOKEN_REQUEST_URL = "@@ACTIONS_ID_TOKEN_REQUEST_URL@@"

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def exponential_backoff[**P, R](
    fn: Callable[P, R],
    *args: P.args,
    **kwargs: P.kwargs,
) -> R:
    max_retries = 5
    initial_delay = 1.0
    exc: Exception | None = None
    for attempt in range(max_retries):
        start_time = time.monotonic()
        try:
            return fn(*args, **kwargs)
        except Exception as e:
            exc = e
            logger.warning(
                "Attempt %d for function %r failed", attempt, fn.__name__, exc_info=e
            )
            time.sleep(initial_delay * (2**attempt))
        finally:
            logger.info(
                "Attempt %d for function %r took %s",
                attempt,
                fn.__name__,
                timedelta(seconds=time.monotonic() - start_time),
            )
    raise Exception(
        f"Failed to execute function {fn.__name__} after {max_retries} attempts"
    ) from exc


def request_oidc_token() -> str:
    response = requests.get(
        ACTIONS_ID_TOKEN_REQUEST_URL,
        params={"audience": NIKS3_SERVER_URL},
        headers={"Authorization": f"Bearer {ACTIONS_ID_TOKEN_REQUEST_TOKEN}"},
    )
    response.raise_for_status()
    return response.json()["value"]


def _collect_extra_paths(env: Mapping[str, str]):
    return {
        **env,
        "PATH": os.pathsep.join(
            path
            for path in (
                EXTRA_PATHS.split(os.pathsep) + env.get("PATH", "").split(os.pathsep)
            )
            if path.strip()
        ),
    }


def perform_push(token: str, env: Mapping[str, str]):
    out_paths = [path.strip() for path in env["OUT_PATHS"].split()]
    logger.info("Uploading %d paths: %r", len(out_paths), out_paths)

    with tempfile.TemporaryDirectory() as temp_dir:
        with open((path := Path(temp_dir) / "auth_token.txt"), "wt") as f:
            f.write(token)
        return subprocess.check_call(
            [
                "niks3",
                "push",
                f"--server-url={NIKS3_SERVER_URL}",
                f"--auth-token-path={path}",
                *out_paths,
            ],
            env=_collect_extra_paths(env),
        )


def perform_gc(token: str, env: Mapping[str, str]):
    with tempfile.TemporaryDirectory() as temp_dir:
        with open((path := Path(temp_dir) / "auth_token.txt"), "wt") as f:
            f.write(token)
        return subprocess.check_call(
            [
                "niks3",
                "gc",
                f"--server-url={NIKS3_SERVER_URL}",
                f"--auth-token-path={path}",
                "--older-than=168h",
            ],
            env=_collect_extra_paths(env),
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.set_defaults(
        func=lambda args: exponential_backoff(
            perform_push, exponential_backoff(request_oidc_token), os.environ
        )
    )
    parser.add_subparsers(dest="action").add_parser(
        "gc", help="Perform garbage collection"
    ).set_defaults(
        func=lambda args: exponential_backoff(
            perform_gc, exponential_backoff(request_oidc_token), os.environ
        )
    )
    args = parser.parse_args()
    args.func(args)
