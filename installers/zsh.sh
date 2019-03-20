#!/usr/bin/env bash
# ZSH-relevant things

zshRoot="$HOME/.oh-my-zsh/custom"

# Spaceship theme
git clone https://github.com/denysdovhan/spaceship-prompt.git "$zshRoot/themes/spaceship-prompt"
ln -s "$zshRoot/themes/spaceship-prompt/spaceship.zsh-theme" "$zshRoot/themes/spaceship.zsh-theme"
perl -pi -e 's/blinks/spaceship/' ~/.zshrc

