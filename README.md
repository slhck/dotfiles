# Dotfiles

This is a repository of my dotfiles and OS X / Linux-specific installers.

**CAVEAT:** None of this is fully automated. Take whatever you need.

# Download the Repo

Prerequisites under Linux:

```
sudo apt update && sudo apt install -y git
cd ~&& git clone https://github.com/slhck/dotfiles
```

Under macOS, download the repo manually.

# Install

Then:

1. Run the `installers/general.sh` script for general tool installation
1. If on macOS, install the Brew formulae from the Brewfile via `brew bundle`
1. Switch to ZSH
    - Through `chsh -s /usr/bin/zsh`
    - If under Linux GUI, change the default shell for GNOME Terminal
1. Run the `installers/zsh.sh` script for zsh-specific stuff
1. Run the `installers/node.sh` script
1. Run the `installers/python.sh` script
1. Run the `installers/gui.sh` script for GUI-relevant stuff
1. Run `scripts/install-scripts.sh` to install all custom scripts to `~/.bin`

# Syncing Software

* Sublime Text 3: Copy the `Packages/User` folder
* iTerm 2:
  * Export/Import settings
  * Colors: `OceanicNext`

# Brewfile creation

```
brew bundle dump --force --describe
```

# License

This repository is licensed under the MIT License.

Further scripts by Evan Hahn from https://codeberg.org/EvanHahn/dotfiles/ under public domain.
