#!/usr/bin/env bash

# Enable docker under Linux
if [[ "$(uname)" == "Linux" ]]; then
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker "${USER}"
fi
