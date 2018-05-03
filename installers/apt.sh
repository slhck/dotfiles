#!/usr/bin/env bash
# Apt installation

sudo apt update

sudo apt install --assume-yes \
    build-essential \
    curl \
    git \
    git-flow \
    git-extras \
    htop \
    p7zip \
    p7zip-full \
    rar \
    unrar \
    wget \
    zsh \
    python-dev \
    python-pip \
    python-numpy \
    python-scipy \
    python-setuptools \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-scipy \
    python3-setuptools \
    vim \
    libreadline-dev \
    libssl-dev \
    zlib1g-dev

# Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs