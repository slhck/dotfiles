#!/usr/bin/env bash

cp ../gitconfig ~/.gitconfig
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