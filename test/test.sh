#!/usr/bin/env bash
#
# Test dotfiles installer in a clean Debian container
#
set -euo pipefail

if [[ $# -ne 0 ]]; then
    echo "Usage: $0"
    echo "(This has no args!)"
    exit 1 
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="dotfiles-test"

echo "==> Building test image..."
docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$REPO_DIR"

echo ""
echo "==> Starting Debian container..."
echo "Run './bootstrap.sh' to test (use -n for dry-run)"
echo ""

docker run -it --rm \
    -v "$REPO_DIR:/dotfiles:ro" \
    -w /dotfiles \
    "$IMAGE_NAME" \
    /bin/bash
