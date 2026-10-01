#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["tomlkit>=0.13,<1"]
# ///
"""Merge shared Codex preferences, preserving private settings and TOML comments."""

import argparse
import copy
from datetime import datetime
import os
from pathlib import Path
import shutil
from collections.abc import MutableMapping

import tomlkit


def merge(current, defaults):
    for key, value in defaults.items():
        if isinstance(value, MutableMapping) and isinstance(current.get(key), MutableMapping):
            merge(current[key], value)
        else:
            current[key] = copy.deepcopy(value)
    return current


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--os", choices=["macos", "linux"], required=True)
    parser.add_argument("--home", type=Path, default=Path.home())
    args = parser.parse_args()
    source = Path(__file__).resolve().parent
    target = args.home / ".codex"
    config = target / "config.toml"
    defaults = tomlkit.parse((source / "config.toml").read_text())
    overlay = source / f"config.{args.os}.toml"
    if overlay.exists():
        merge(defaults, tomlkit.parse(overlay.read_text()))
    original = config.read_text() if config.exists() else ""
    content = tomlkit.dumps(merge(tomlkit.parse(original), defaults))
    # Parse before touching the live config.
    tomlkit.parse(content)
    if content == original:
        print("Shared Codex settings already current")
        return
    target.mkdir(parents=True, exist_ok=True)
    if config.exists():
        backup = args.home / ".dotfiles-backup" / datetime.now().strftime("%Y%m%d-%H%M%S-%f") / ".codex"
        backup.mkdir(parents=True)
        shutil.copy2(config, backup / "config.toml")
        print(f"Backed up Codex settings to {backup}")
    temporary = target / f".config-dotfiles-{os.getpid()}.toml"
    try:
        temporary.write_text(content)
        temporary.chmod(0o600)
        temporary.replace(config)
    finally:
        temporary.unlink(missing_ok=True)
    print("Installed shared Codex settings")


if __name__ == "__main__":
    main()
