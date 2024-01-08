# Pyenv and Python pips

pythonVersion="3.12.1"

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
    commitizen \
    csvkit \
    "dask[complete]" \
    docx2pdf \
    flake8 \
    gitchangelog \
    gitup \
    pandas \
    pandoc \
    pandocfilters \
    paramiko \
    pyflakes \
    pylint \
    pystache \
    ruff \
    thefuck \
    tqdm \
    twine \
    wheel \
    visidata \
    yt-dlp
