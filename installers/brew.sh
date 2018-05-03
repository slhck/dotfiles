#!/usr/bin/env bash
# macOS Brew installation

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap caskroom/cask

brew cask install \
    betterzipql \
    qlcolorcode \
    qlmarkdown \
    qlprettypatch \
    qlstephen \
    quicklook-csv \
    quicklook-json \
    quicknfo \
    suspicious-package \
    webpquicklook \
    mpv \
    osxfuse

brew install \
    7z \
    autojump \
    bash \
    coreutils \
    ddclient \
    ddrescue \
    dos2unix \
    duti \
    exiftool \
    exiv2 \
    findutils \
    fzf \
    ghostscript \
    git \
    git-extras \
    git-flow \
    gnu-sed \
    grc \
    grep \
    gpac \
    id3tool \
    imagemagick \
    less \
    lesspipe \
    man2html \
    media-info \
    mercurial \
    nmap \
    node \
    numpy \
    opencv \
    pandoc \
    poppler \
    python \
    python2 \
    qt \
    r \
    rbenv \
    readline \
    rename \
    rsync \
    ruby-build \
    scipy \
    scons \
    sl \
    sqlite \
    ssh-copy-id \
    subversion \
    tcl-tk \
    terminal-notifier \
    thefuck \
    tldr \
    tmux \
    tree \
    unrar \
    wget \
    youtube-dl \
    zsh

# ffmpeg
brew install ffmpeg \
    --with-fdk-aac \
    --with-libass \
    --with-libsoxr \
    --with-libssh \
    --with-tesseract \
    --with-libvidstab \
    --with-opencore-amr \
    --with-openh264 \
    --with-openjpeg \
    --with-openssl \
    --with-rtmpdump \
    --with-schroedinger \
    --with-sdl2 \
    --with-tools \
    --with-webp \
    --with-x265 \
    --with-xz \
    --with-zeromq \
    --with-fontconfig \
    --with-freetype \
    --with-frei0r \
    --with-libbluray \
    --with-libcaca \
    --with-libvorbis \
    --with-libvpx \
    --with-opus \
    --with-speex \
    --with-theora \
    --with-two-lame \
    --with-wavpack