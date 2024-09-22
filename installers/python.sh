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

pipx install \
    commitizen \
    csvkit \
    docx2pdf \
    gitchangelog \
    gitup \
    pystache \
    ruff \
    thefuck \
    twine \
    wheel \
    visidata \
    yt-dlp
