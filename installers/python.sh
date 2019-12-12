# Pyenv and Python pips

pythonVersion="3.7.5"

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
    gitup \
    flake8 \
    pyflakes \
    pylint \
    pandoc \
    pandocfilters \
    youtube-dl \
    tqdm \
    thefuck \
    csvkit \
    gitchangelog \
    pandas \
    tqdm \
    twine
