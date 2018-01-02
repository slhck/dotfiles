#!/usr/bin/env ruby
#
# OS X installer

require_relative 'functions.rb'

# SSH key
run "ssh-keygen -t rsa"

# Vim Ctrl-P
run "mkdir -p ~/.vim && cd ~/.vim && git clone https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim"

# Homebrew
run %( ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" )
run "brew tap caskroom/cask"

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
  7z
  autojump
  bash
  coreutils
  dos2unix
  duti
  exiftool
  exiv2
  findutils
  fzf
  ghostscript
  git
  git-extras
  git-flow
  grc
  grep
  gpac
  id3tool
  imagemagick
  less
  lesspipe
  man2html
  media-info
  mercurial
  nmap
  node
  opencv
  pandoc
  poppler
  python
  python3
  qt
  r
  rbenv
  readline
  rename
  rsync
  ruby-build
  scons
  sl
  sqlite
  ssh-copy-id
  subversion
  tcl-tk
  terminal-notifier
  tldr
  tmux
  tree
  unrar
  wget
  youtube-dl
  zsh
)
run "brew install " + formulae.join(" ")

run "brew install numpy --with-python3"
run "brew install scipy --with-python3"

# ffmpeg
run "brew install ffmpeg \
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

# FZF
run "/usr/local/opt/fzf/install"

# Spaceship theme
run "curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.zsh | zsh"