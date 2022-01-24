#!/usr/bin/env bash
# Apt installation

sudo apt update

sudo apt install --assume-yes \
    autoconf \
    bison \
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
    libdb-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm6 \
    libncurses5-dev \
    libreadline-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libyaml-dev \
    mosh \
    p7zip \
    p7zip-full \
    pngquant \
    pv \
    pwgen \
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

# other, non-apt tools

export DEBIAN_FRONTEND=noninteractive
mkdir -p "$HOME/.local/bin"

# fd
curl --silent "https://api.github.com/repos/sharkdp/fd/releases/latest" | \
    jq -r '.assets[] | .browser_download_url' | \
    grep 'amd64' | \
    grep -v musl | \
    xargs -L 1 wget -O fd.deb
sudo dpkg -i fd.deb
rm -f fd.deb
[[ -f /usr/bin/fdfind ]] && ln -s /usr/bin/fdfind "$HOME/.local/bin/fd"

# bat
curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | \
    jq -r '.assets[] | .browser_download_url' | \
    grep 'amd64' | \
    grep -v musl | \
    xargs -L 1 wget -O bat.deb
sudo dpkg -i bat.deb
rm -f bat.deb
[[ -f /usr/bin/batcat ]] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"

# hyperfine
curl --silent "https://api.github.com/repos/sharkdp/hyperfine/releases/latest" | \
    jq -r '.assets[] | .browser_download_url' | \
    grep 'amd64' | \
    grep -v musl | \
    xargs -L 1 wget -O hyperfine.deb
sudo dpkg -i hyperfine.deb
rm -f hyperfine.deb

# Linuxbrew is optional
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
