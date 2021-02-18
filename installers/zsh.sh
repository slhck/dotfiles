#!/usr/bin/env zsh
# ZSH-relevant things

if [ -n "$ZSH_VERSION" ]; then
    zshRoot="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"

    # Spaceship theme
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$zshRoot/themes/spaceship-prompt"
    ln -s "$zshRoot/themes/spaceship-prompt/spaceship.zsh-theme" "$zshRoot/themes/spaceship.zsh-theme"
    perl -pi -e 's/blinks/spaceship/' ~/.zshrc

    # Syntax highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${zshRoot}/plugins/zsh-syntax-highlighting"

    # Auto suggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions "${zshRoot}/plugins/zsh-autosuggestions"

    echo "Reload your ZSH shell!"
else
    echo "Not running ZSH!"
    exit 1
fi

