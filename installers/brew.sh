#!/usr/bin/env bash
# macOS Brew installation

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# then load from brew bundle:
brew bundle install --file="$(dirname "$0")/Brewfile"
