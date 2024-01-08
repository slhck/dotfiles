# -----------------------------------------------
# Set up the Environment
# -----------------------------------------------

EDITOR=vim
PAGER=less
COLORTERM=yes

PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/texbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH
# de-dupe path, https://unix.stackexchange.com/a/149054/5893
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

export TERM EDITOR PAGER DISPLAY LS_COLORS COLORTERM PATH HISTFILE HISTSIZE SAVEHIST

# set locale if needed
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# -----------------------------------------------
# oh-my-zsh
# -----------------------------------------------

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Use blinks with: http://ethanschoonover.com/solarized
ZSH_THEME="blinks"
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_DIR_TRUNC=0

COMPLETION_WAITING_DOTS="true"

# Plugins to load
plugins=(git git-extras github ruby macos gem svn docker docker-compose vagrant virtualenv python web-search zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# -----------------------------------------------
#  Keybindings for iTerm2 in OS X, set it to xterm
#  defaults though.
# -----------------------------------------------

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word

bindkey '^W' vi-backward-kill-word
bindkey '^f' vi-forward-word
bindkey '^b' vi-backward-word

# -----------------------------------------------
# Load zsh modules
# -----------------------------------------------

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# compinit initializes various advanced completions for zsh
autoload -Uz compinit && compinit

# zmv is a batch file rename tool; e.g. zmv '(*).text' '$1.txt'
autoload zmv

# -----------------------------------------------
# Set up zsh autocompletions
# -----------------------------------------------

# General completion technique
zstyle ':completion:*' completer _complete _correct _approximate _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete

# Completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

# Expand partial paths
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# Separate matches into groups
zstyle ':completion:*:matches' group 'yes'

# Describe each match group.
zstyle ':completion:*:descriptions' format "%B%d%b"

# Messages/warnings format
zstyle ':completion:*:messages' format '%B%U%d%u%b'
zstyle ':completion:*:warnings' format '%B%Uno match for: %d%u%b'

# Describe options in full
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# -----------------------------------------------
# Set zsh options
# -----------------------------------------------

setopt \
  auto_cd \
  no_beep \
  correct \
  auto_list \
  auto_pushd \
  complete_in_word \
  extended_glob \
  zle

unsetopt \
  correct_all \
  hist_verify

# Ununsed
# glob_complete \
# setopt complete_aliases

# -----------------------------------------------
# Shell Aliases
# -----------------------------------------------

## Command Aliases
alias x=exit
alias c=clear
alias s=screen
alias t=tmux
alias ta='tmux a'
alias tls='tmux ls'
alias vi='vim'
#alias ls='ls --color=auto -F'
#alias l='ls -lAF --color=auto'
alias zrc='vim ~/.zshrc'
alias e='smartextract'
alias pie='perl -pi -e'

## Listings
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias llha='ls -lha'

## ZMV-specific
alias zcp='zmv -C'
alias zln='zmv -L'
alias mmv='noglob zmv -W'

## Pipe Aliases (Global)
alias -g L='|less'
alias -g G='|grep'
alias -g T='|tail'
alias -g H='|head'
alias -g W='|wc -l'
alias -g S='|sort'

## Special Root Aliases
[ $UID = 0 ] && \
  alias m='make' && \
  alias mi='make install' && \
  alias rm='rm -i' && \
  alias mv='mv -i' && \
  alias cp='cp -i'

## Git
alias gcam='git add -A && git commit -m "update" && git pull --rebase && git push --all'
alias gups='git submodule update --rebase --remote --init --recursive'
alias gcane='git add -A && git commit --amend --no-edit'
alias gpa='git push --all && git push --tags'
alias git-update-fork='git fetch upstream && git checkout master && git merge upstream/master'

# -----------------------------------------------
#  User-defined Functions
# -----------------------------------------------

# check the weather
weather() { curl v2.wttr.in }

# upload a file to transfer.sh
transfer(){ if [ $# -eq 0 ];then echo "No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>">&2;return 1;fi;if tty -s;then file="$1";file_name=$(basename "$file");if [ ! -e "$file" ];then echo "$file: No such file or directory">&2;return 1;fi;if [ -d "$file" ];then file_name="$file_name.zip" ,;(cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "http://transfer.sh/$file_name"|tee /dev/null,;else cat "$file"|curl --progress-bar --upload-file "-" "http://transfer.sh/$file_name"|tee /dev/null;fi;else file_name=$1;curl --progress-bar --upload-file "-" "http://transfer.sh/$file_name"|tee /dev/null;fi;}

# cd and list
cl() {
  cd "$@"
  ls -la
}

# mkdir and cd there
mc() {
  mkdir -p "$*" && cd "$*"
}

# Usage: smartextract <file>
# Description: extracts archived files / mounts disk images
# Note: .dmg/hdiutil is Mac OS X-specific.
smartextract () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)  tar -jxvf "$1"        ;;
            *.tar.gz)   tar -zxvf "$1"        ;;
            *.bz2)      bunzip2 "$1"          ;;
            *.dmg)      hdiutil mount "$1"    ;;
            *.gz)       gunzip "$1"           ;;
            *.rar)      unrar x "$1"          ;;
            *.tar)      tar -xvf "$1"         ;;
            *.tbz2)     tar -jxvf "$1"        ;;
            *.tgz)      tar -zxvf "$1"        ;;
            *.zip)      unzip "$1"            ;;
            *.Z)        uncompress "$1"       ;;
            *.7z)       7z x "$1"             ;;
            *)          echo "'$1' cannot be extracted/mounted via smartextract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

psgrep() {
    if [ ! -z $1 ] ; then
        echo "Grepping for processes matching $1..."
        ps aux | grep $1 | grep -v grep
    else
        echo "!! Need name to grep for"
    fi
}

embed-fonts() {
  # http://stackoverflow.com/q/2670809/
  if [ "$#" -ne 2 ]; then
    echo "Usage: embed-fonts <input> <output>" && return
  fi
  gs \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/default \
   -dCompressFonts=true \
   -dSubsetFonts=true \
   -dNOPAUSE \
   -dBATCH \
   -dQUIET \
   -sDEVICE=pdfwrite \
   -sOutputFile="$2" \
   -c "<</NeverEmbed [ ]>> setdistillerparams" \
   -f "$1"
}

compress-pdf() {
  # /screen selects low-resolution output similar to the Acrobat Distiller "Screen Optimized" setting.
  # /ebook selects medium-resolution output similar to the Acrobat Distiller "eBook" setting.
  # /printer selects output similar to the Acrobat Distiller "Print Optimized" setting.
  # /prepress selects output similar to Acrobat Distiller "Prepress Optimized" setting.
  # /default selects output intended to be useful across a wide variety of uses, possibly at the expense of a larger output file.
  #
  # You can add this as a macOS Automator action, see "workflows/Compress PDF"
  if [ "$#" -ne 3 ]; then
    echo "Usage: compress-pdf <input> <preset> <output>"
    echo ""
    echo "<preset>: one of [screen|ebook|printer|prepress|default]"
    return
  fi
  gs \
  -dCompatibilityLevel=1.4 \
  -dPDFSETTINGS=/"$2" \
  -dNOPAUSE \
  -dBATCH \
  -dQUIET \
  -sDEVICE=pdfwrite \
  -sOutputFile="$3" \
  -f "$1"
}

doc-to-json() {
  # convert a document to a valid JSON string in GFM format
  pandoc "$1" -t gfm-raw_html --wrap=preserve -o - | python -c 'import json; import sys; print(json.dumps(sys.stdin.read()))'
}

# select a directory and cd to it upon exit
# based on: https://news.ycombinator.com/item?id=32106770
fcd() {
  local dir;

  while true; do
    # exit with ^D
    dir="$(ls -a1p | grep '/$' | grep -v '^./$' | fzf --reverse --no-multi --preview 'pwd' --preview-window=up,1,border-none --no-info)"
    if [[ -z "${dir}" ]]; then
      break
    else
      cd "${dir}"
    fi
  done
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi) || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# Use fd and fzf to get the args to a command.
# Works only with zsh
# Examples:
# f mv # To move files. You can write the destination after selecting the files.
# f 'echo Selected:'
# f 'echo Selected music:' --extension mp3
# fm rm # To rm files in current directory
f() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf -m)}" )
    test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
}

# Like f, but not recursive.
fm() {
  f "$@" --max-depth 1
}

# shortcut to bump a file containing just a version number
semver-bump() {
  if ! command -v semver >/dev/null 2>&1; then
    echo "Installing semver ..."
    wget -O /usr/local/bin/semver https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver
    chmod +x /usr/local/bin/semver
  fi
  local file="$1"
  local version=$(cat "$file" | tr -d '[:space:]')
  local bumpType="${2:-patch}"
  semver bump "$bumpType" "$version" > "$file"
}

# generate a random password
pw() {
  pwgen -y 24 -1 "$@"
}

# -----------------------------------------------
#  Color for ls
# -----------------------------------------------

export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;36:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.bz2=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.sit=01;31:*.hqx=01;31:*.jpg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mpg=01;35:*.avi=01;35:*.mov=01;35:*.app=01;33:*.c=00;33:*.php=00;33:*.pl=00;33:*.cgi=00;33:'
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# -----------------------------------------------
#  rbenv
# -----------------------------------------------

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
  if which rbenv > /dev/null; then eval "$(rbenv init - zsh)"; fi
fi

# -----------------------------------------------
# TheFuck
# -----------------------------------------------
if which thefuck > /dev/null; then eval $(thefuck --alias); fi

# -----------------------------------------------
# fzf
# -----------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------------------------
# NVM
# -----------------------------------------------

# broken, see: https://github.com/nvm-sh/nvm/issues/2362#issuecomment-746108881
setopt no_aliases
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
setopt aliases

# -----------------------------------------------
# Homebrew
# -----------------------------------------------

alias bubu='brew update && brew upgrade'

# Remove Git completion that Homebrew ships
[[ -f /usr/local/share/zsh/site-functions/_git ]] && \
  rm  -f /usr/local/share/zsh/site-functions/_git


# END: Global configuration file
