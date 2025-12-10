#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from os import chmod, environ
from pathlib import Path
from shlex import quote
from shutil import which
from tempfile import NamedTemporaryFile
from textwrap import dedent
from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse


def write_temporary_script(
    content: str, *, prefix: str = "", suffix: str = "", mode: int = 0o755
) -> Path:
    with NamedTemporaryFile(mode="w", suffix=suffix, prefix=prefix, delete=False) as f:
        f.write(content)
        script_path = f.name
    chmod(script_path, mode)
    return Path(script_path)


secret_key_path = write_temporary_script(
    environ["NIX_SIGN_SECRET_KEY"],
    prefix="nix-sign-secret",
    suffix=".key",
    mode=0o644,
)


def build_nix_cache_uri(nix_cache_uri: str, secret_key_path: Path) -> str:
    parsed = urlparse(nix_cache_uri)
    query_params = parse_qsl(parsed.query) + [
        ("secret-key", str(secret_key_path.absolute())),
        ("multipart-upload", "true"),
        ("compression", "zstd"),
        ("index-debug-info", "true"),
    ]
    new_query = urlencode(query_params)
    return urlunparse(parsed._replace(query=new_query))


final_uri = build_nix_cache_uri(environ["NIX_CACHE_URI"], secret_key_path)

script_content = dedent(f"""\
    #!/bin/sh
    set -eu
    set -f # disable globbing
    export IFS=' ' \
        AWS_SECRET_ACCESS_KEY={quote(environ["AWS_SECRET_ACCESS_KEY"])} \
        AWS_ACCESS_KEY_ID={quote(environ["AWS_ACCESS_KEY_ID"])}
    echo "Uploading paths" $OUT_PATHS
    exec {quote(which("nix") or "")} copy --to {quote(final_uri)} $OUT_PATHS
""")

script_path = write_temporary_script(
    script_content, prefix="post-build-hook-", suffix=".sh", mode=0o755
)
with open(environ["GITHUB_OUTPUT"], "a") as f:
    f.write(f"post-build-hook={script_path}\n")
