#!/usr/bin/env bash
# General installation stuff
set -e

# apt or Homebrew
if [[ "$(uname)" == "Darwin" ]]; then
    ./brew.sh
elif [[ "$(uname)" == "Linux" ]]; then
    ./apt.sh
else
fi

# SSH
cat /dev/zero | ssh-keygen -t rsa -q -N ""

# oh-my-zsh
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# Rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
(cd ~/.rbenv && src/configure && make -C src)

# FZF and autojump are not handled by apt
if [[ "$(uname)" == "Linux" ]]; then
    # FZF
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    # autojump
    git clone git://github.com/joelthelion/autojump.git ~/autojump
    (cd ~/autojump && ./install.py)
    rm -rf ~/autojump
fi

# Vim
mkdir -p ~/.vim
(cd ~/.vim && git clone https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim)

# Node
./node.sh

# tmux
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
