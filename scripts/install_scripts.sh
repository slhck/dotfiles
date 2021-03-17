#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

mkdir -p "$HOME/.bin"

cp -v -- release-python.sh "$HOME/.bin"
