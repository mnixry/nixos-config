#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from os import environ
from subprocess import check_call
import time
import requests

EXTRA_PATHS = "@@EXTRA_PATHS@@"
NIKS3_SERVER_URL = "@@NIKS3_SERVER_URL@@"
ACTIONS_ID_TOKEN_REQUEST_TOKEN = "@@ACTIONS_ID_TOKEN_REQUEST_TOKEN@@"
ACTIONS_ID_TOKEN_REQUEST_URL = "@@ACTIONS_ID_TOKEN_REQUEST_URL@@"

start_time = time.monotonic()
response = requests.get(
    ACTIONS_ID_TOKEN_REQUEST_URL,
    params={"audience": NIKS3_SERVER_URL},
    headers={"Authorization": f"Bearer {ACTIONS_ID_TOKEN_REQUEST_TOKEN}"},
)
response.raise_for_status()
token = response.json()["value"]
print(f"OIDC token request took {(time.monotonic() - start_time) * 1000:.2f} ms")

out_paths = [path.strip() for path in environ["OUT_PATHS"].split(None)]
print("Uploading paths: ", *out_paths)

check_call(
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
