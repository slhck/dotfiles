#!/usr/bin/env bash
#
# Create config files

cd "$(dirname "$0")"

cp ../gitconfig ~/.gitconfig
cp ../flake8 ~/.flake8
cp ../pdbrc ~/.pdbrc
cp ../pypirc ~/.pypirc
cp ../tmux.conf ~/.tmux.conf
cp ../vimrc ~/.vimrc

cp ../zshrc ~/.zshrc

if [[ "$(uname)" == "Darwin" ]]; then
    cat ../zshrc.osx >> ~/.zshrc
elif [[ "$(uname)" == "Linux" ]]; then
    cat ../zshrc.linux >> ~/.zshrc
else
fi