#!/bin/bash
#
# Add a text string to a PDF file.
#
# Requirements: qpdf, enscript, ps2pdf
#
# Author: Werner Robitza
# License: MIT

set -e

MARGIN=2
SIZE=10

usage() {
    echo "Usage: $0 [-m,--margin MARGIN] [-s,--size SIZE] <text_string> <input_file> <output_file>"
    echo
    echo "Options:"
    echo "  -m, --margin MARGIN   Set the margin in PS units (default: $MARGIN)"
    echo "  -s, --size SIZE       Set the font size in pt (default: $SIZE)"
    echo "  -h, --help            Show this help and exit"
    echo
    echo "Example: $0 'Hello World' input.pdf output.pdf"
    exit 1
}

if ! command -v enscript >/dev/null 2>&1; then
    echo "enscript is not installed"
    exit 1
fi

if ! command -v ps2pdf >/dev/null 2>&1; then
    echo "ps2pdf is not installed"
    exit 1
fi

# parse args
# parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--margin)
            MARGIN="$2"
            shift
            ;;
        -s|--size)
            SIZE="$2"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ $# -ne 3 ]; then
    usage
fi

# get the text
text="$1"

# Set the input and output filenames
input_file="$2"
output_file="$3"

# Create a temporary file
tmpfile=$(mktemp)

echo "$text" | \
  enscript -B -f "Helvetica-Bold${SIZE}" --margins="${MARGIN}":"${MARGIN}":"${MARGIN}:${MARGIN}" -o- | \
  ps2pdf - "$tmpfile" && \
  qpdf "$input_file"  --overlay "$tmpfile" -- "$output_file"

echo "Done"
