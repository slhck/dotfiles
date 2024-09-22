#!/usr/bin/env bash
# Ruby and Gems

if ! command -v rbenv >/dev/null; then
    echo "rbenv not installed!"
    exit 1
fi

# latest stable
rbenv install -l

rbenv rehash
