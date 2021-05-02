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
    pngquant \
    pv \
    python3-dev \
    python3-numpy \
    python3-pip \
    python3-scipy \
    python3-setuptools \
    rar \
    tree \
    ufw \
    unrar \
    vim \
    wget \
    xclip \
    zlib1g-dev \
    zsh

# fd
fdUrl=$(curl --silent "https://api.github.com/repos/sharkdp/fd/releases/latest" | jq -r '.assets[] | .browser_download_url' | grep 'amd64' | grep -v musl)
wget -O fd.deb "$fdUrl"
sudo dpkg -i fd.deb
rm -rf fd.deb

# Linuxbrew is optional
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
