#!/usr/bin/env bash
#
# NVM and nodejs
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

source ~/.zshrc

nvm install node

npm install -g \
    jsonlint \
    jshint \
    grunt