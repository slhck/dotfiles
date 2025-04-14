#!/usr/bin/env bash
# General installation stuff
set -e

cd "$(dirname "$0")"

# apt or Homebrew
if [[ "$(uname)" == "Darwin" ]]; then
    ./brew.sh
elif [[ "$(uname)" == "Linux" ]]; then
    ./apt.sh
else
    echo "Wrong OS"
fi

# SSH
cat /dev/zero | ssh-keygen -t rsa -q -N ""

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Not handled by apt:
# FZF
# Autojump
# Rbenv
# Pyenv
# NVM
if [[ "$(uname)" == "Linux" ]]; then
    # FZF
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --completion --key-bindings --update-rc

    # autojump
    git clone git://github.com/joelthelion/autojump.git ~/autojump
    (cd ~/autojump && ./install.py)
    rm -rf ~/autojump

    # Rbenv
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

    # Pyenv
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

    # NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

    # uv
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "No installing FZF, Autojump, Rbenv, Pyenv and NVM since they come from Homebrew"
fi

# Vim
mkdir -p ~/.vim
(cd ~/.vim && git clone https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim)

# tmux
cd
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

./copy_dotfiles.sh

echo "Now set zsh as your default shell using chsh, and reload the shell!"
