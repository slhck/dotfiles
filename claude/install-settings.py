#!/usr/bin/env python3
"""Apply shared Claude defaults while retaining private and integration settings."""

import argparse
import copy
import json
import os
from pathlib import Path
import shutil
from datetime import datetime


def merge(current, defaults):
    result = copy.deepcopy(current)
    for key, value in defaults.items():
        if key == "hooks":
            hooks = result.setdefault("hooks", {})
            for event, groups in value.items():
                existing = hooks.setdefault(event, [])
                for group in groups:
                    match = next((g for g in existing if g.get("matcher") == group.get("matcher")), None)
                    if match is None:
                        existing.append(copy.deepcopy(group))
                    else:
                        for hook in group["hooks"]:
                            if hook not in match.setdefault("hooks", []):
                                match["hooks"].append(copy.deepcopy(hook))
        elif isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = merge(result[key], value)
        else:
            result[key] = copy.deepcopy(value)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--os", choices=["macos", "linux"], required=True)
    parser.add_argument("--home", type=Path, default=Path.home())
    args = parser.parse_args()
    source = Path(__file__).resolve().parent
    target = args.home / ".claude"
    settings = target / "settings.json"
    defaults = json.loads((source / "settings.json").read_text())
    overlay = source / f"settings.{args.os}.json"
    if overlay.exists():
        defaults = merge(defaults, json.loads(overlay.read_text()))
    current = json.loads(settings.read_text()) if settings.exists() else {}
    content = json.dumps(merge(current, defaults), indent=2) + "\n"
    target.mkdir(parents=True, exist_ok=True)
    if settings.exists() and settings.read_text() != content:
        backup = args.home / ".dotfiles-backup" / datetime.now().strftime("%Y%m%d-%H%M%S-%f") / ".claude"
        backup.mkdir(parents=True)
        shutil.copy2(settings, backup / "settings.json")
        print(f"Backed up Claude settings to {backup}")
    temporary = target / f".settings-dotfiles-{os.getpid()}.json"
    try:
        temporary.write_text(content)
        temporary.chmod(0o600)
        temporary.replace(settings)
    finally:
        temporary.unlink(missing_ok=True)
    shutil.copy2(source / "statusline-command.sh", target / "statusline-command.sh")
    (target / "statusline-command.sh").chmod(0o755)
    print("Installed shared Claude settings and status line")


if __name__ == "__main__":
    main()
