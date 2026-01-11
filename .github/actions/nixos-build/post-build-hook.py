#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from datetime import timedelta
import logging
from os import environ
from subprocess import check_call
import time
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


out_paths = [path.strip() for path in environ["OUT_PATHS"].split(None)]
logger.info("Uploading %d paths: %r", len(out_paths), out_paths)


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


token = exponential_backoff(request_oidc_token)
returncode = exponential_backoff(
    check_call,
    [
        "niks3",
        "push",
        "--server-url",
        NIKS3_SERVER_URL,
        "--auth-token",
        token,
        *out_paths,
    ],
    env={**environ, "PATH": EXTRA_PATHS + ":" + environ.get("PATH", "")},
)
