# Pyenv and Python pips

pythonVersion="3.7.2"

pyenv install "$pythonVersion"
pyenv rehash
pyenv global "$pythonVersion"

pip3 install \
    gitup \
    flake8 \
    pyflakes \
    pylint \
    CodeIntel \
    notebook \
    pandoc \
    pandocfilters \
    youtube-dl \
    tqdm \
    thefuck