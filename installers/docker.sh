#!/usr/bin/env bash

# Enable docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ${USER}
