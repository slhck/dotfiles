#!/usr/bin/env bash
# ZSH-relevant things

if [ -n "$ZSH_VERSION" ]; then
    zshRoot="$HOME/.oh-my-zsh/custom"

    # Spaceship theme
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$zshRoot/themes/spaceship-prompt"
    ln -s "$zshRoot/themes/spaceship-prompt/spaceship.zsh-theme" "$zshRoot/themes/spaceship.zsh-theme"
    perl -pi -e 's/blinks/spaceship/' ~/.zshrc

    echo "Reload your ZSH shell!"
else
    echo "Not running ZSH!"
    exit 1
fi

