#!/usr/bin/env bash
# Apt installation

sudo apt update

sudo apt install --assume-yes \
    build-essential \
    byobu \
    curl \
    docker-compose \
    docker.io \
    git \
    git-extras \
    git-flow \
    htop \
    jq \
    libbz2-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    mosh \
    p7zip \
    p7zip-full \
    pngquant
    pv \
    python-dev \
    python-numpy \
    python-pip \
    python-scipy \
    python-setuptools \
    python3-dev \
    python3-numpy \
    python3-pip \
    python3-scipy \
    python3-setuptools \
    rar \
    ufw \
    unrar \
    vim \
    wget \
    xclip \
    zlib1g-dev \
    zsh

# Linuxbrew is optional
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
