# Pyenv and Python pips

pythonVersion="3.13.2"

if ! command -v pyenv >/dev/null; then
    echo "pyenv not installed!"
    exit 1
fi

pyenv install "$pythonVersion" && pyenv rehash && pyenv global "$pythonVersion"

if [[ "$(pyenv version-name)" != "$pythonVersion" ]]; then
    echo "pyenv version is not correctly set!"
    exit 1
fi

# no longer needed, uv(x) handles it
# pipx install \
#     commitizen \
#     csvkit \
#     docx2pdf \
#     gitchangelog \
#     gitup \
#     markitdown \
#     pystache \
#     ruff \
#     thefuck \
#     twine \
#     wheel \
#     visidata \
#     yt-dlp
