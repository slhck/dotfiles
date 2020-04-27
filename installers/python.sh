# Pyenv and Python pips

pythonVersion="3.8.1"

if ! command -v pyenv >/dev/null; then
    echo "pyenv not installed!"
    exit 1
fi

pyenv install "$pythonVersion" && pyenv rehash && pyenv global "$pythonVersion"

if [[ "$(pyenv version-name)" != "$pythonVersion" ]]; then
    echo "pyenv version is not correctly set!"
    exit 1
fi

pip3 install \
    black \
    csvkit \
    dephell \
    flake8 \
    gitchangelog \
    gitup \
    pandas \
    pandoc \
    pandocfilters \
    pyflakes \
    pylint \
    pystache \
    thefuck \
    tqdm \
    twine \
    wheel \
    youtube-dl
