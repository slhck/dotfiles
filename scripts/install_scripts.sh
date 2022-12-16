#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

mkdir -p "$HOME/.bin"

for script in *; do
    # skip if the script is this script
    if [[ "$script" == "install_scripts.sh" ]]; then
        continue
    fi

    if [[ -f "$script" && -x "$script" ]]; then
        cp -v -- "$script" "$HOME/.bin"
    fi
done
