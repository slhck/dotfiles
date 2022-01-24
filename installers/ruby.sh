# Ruby and Gems

rubyVersion="3.0.1"

if ! command -v rbenv >/dev/null; then
    echo "rbenv not installed!"
    exit 1
fi

rbenv install "$rubyVersion" && rbenv rehash && rbenv global "$rubyVersion"

if [[ "$(rbenv version-name)" != "$rubyVersion" ]]; then
    echo "rbenv version is not correctly set!"
    exit 1
fi

gem install \
  imap-backup
