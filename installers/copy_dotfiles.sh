#!/usr/bin/env bash
#
# Create config files

cd "$(dirname "$0")"

cp -v ../gitconfig ~/.gitconfig
cp -v ../gitignore ~/.gitignore
cp -v ../flake8 ~/.flake8
cp -v ../pdbrc ~/.pdbrc
cp -v ../pypirc ~/.pypirc
cp -v ../tmux.conf ~/.tmux.conf
cp -v ../vimrc ~/.vimrc
cp -v ../Rprofile ~/.Rprofile

cp -v ../zshrc ~/.zshrc

if [[ "$(uname)" == "Darwin" ]]; then
    cat ../zshrc.osx >> ~/.zshrc
elif [[ "$(uname)" == "Linux" ]]; then
    cat ../zshrc.linux >> ~/.zshrc
else
    echo "Wrong OS"
fi