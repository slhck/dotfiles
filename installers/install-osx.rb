#!/usr/bin/env ruby
#
# OS X installer

require_relative 'functions.rb'

# XCode
run "sudo xcode-select -switch /usr/bin"

# SSH key
run "ssh-keygen -t rsa"

# Vim Ctrl-P
run "mkdir -p ~/.vim && cd ~/.vim && git clone https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim"

# Homebrew
run %( ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" )
run "brew tap caskroom/cask"
run "brew install brew-cask"

# Homebrew casks
casks = %w(
  betterzipql
  qlcolorcode
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-csv
  quicklook-json
  quicknfo
  suspicious-package
  webpquicklook
  mpv
  osxfuse
)
run "brew cask install " + casks.join(" ")

# Homebrew formulae
formulae = %w(
  autojump
  bash
  coreutils
  dos2unix
  findutils
  fzf
  ghostscript
  git
  git-extras
  git-flow
  grc
  id3tool
  imagemagick
  lesspipe
  man2html
  media-info
  mercurial
  nmap
  pandoc
  python
  python3
  rbenv
  ruby-build
  sl
  ssh-copy-id
  tcl-tk
  terminal-notifier
  tree
  unrar
  wget
  youtube-dl
  zsh
)
run "brew install " + formulae.join(" ")

run "/usr/local/opt/fzf/install"

# ffmpeg
run "brew install ffmpeg \
--with-libebur128 \
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
--with-wavpack"

# oh-my-zsh
run "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"