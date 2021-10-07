# Pyenv and Python pips

pythonVersion="3.9.0"

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
    docx2pdf \
    flake8 \
    gitchangelog \
    gitup \
    pandas \
    pandoc \
    pandocfilters \
    pyflakes \
    pylint \
    git+https://github.com/sarnold/pystache \
    thefuck \
    tqdm \
    twine \
    wheel \
    youtube-dl
