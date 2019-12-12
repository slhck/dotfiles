#/usr/bin/env bash
#
# Linux and macOS GUI stuff

if [[ "$(uname)" == "Linux" ]]; then
    # Sublime
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text

    # Themes
    sudo add-apt-repository ppa:tista/adapta
    sudo apt update
    sudo apt install \
        gnome-tweak-tool
        numix-gtk-theme \
        numix-icon-theme \
        adapta-gtk-theme

    # Other important stuff
    sudo apt install \
        texlive-full \
        pandoc \
        pandoc-citeproc
elif [[ "$(uname)" == "Darwin" ]]; then
    # Python packages for development
    pip3 install \
        CodeIntel \
        notebook
fi

