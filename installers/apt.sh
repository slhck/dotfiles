#!/usr/bin/env bash
# Apt installation

sudo apt update

sudo apt install --assume-yes \
    autojump \
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
    zlib1g-dev \
    libsqlite3-dev \
    libbz2-dev

# Docker
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ${USER}

# Pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
