#!/usr/bin/env bash
#
# A script to download a YouTube music video and normalize it.
# This is opinionated and normalizes to an 128k mono mp3 file for our kid's music box.
#
# Author: Werner Robitza
# License: MIT

# ==============================================================================

# Color snippets
# Bashly, https://github.com/DannyBen/bashly
# Licensed under the MIT License (MIT)
# 
# Copyright (c) Danny Ben Shitrit
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

print_in_color() {
  local color="$1"
  shift
  if [[ -z ${NO_COLOR+x} ]]; then
    printf "$color%b\e[0m\n" "$*"
  else
    printf "%b\n" "$*"
  fi
}

red() { print_in_color "\e[31m" "$*"; }
green() { print_in_color "\e[32m" "$*"; }
yellow() { print_in_color "\e[33m" "$*"; }
blue() { print_in_color "\e[34m" "$*"; }
magenta() { print_in_color "\e[35m" "$*"; }
cyan() { print_in_color "\e[36m" "$*"; }
bold() { print_in_color "\e[1m" "$*"; }
underlined() { print_in_color "\e[4m" "$*"; }
red_bold() { print_in_color "\e[1;31m" "$*"; }
green_bold() { print_in_color "\e[1;32m" "$*"; }
yellow_bold() { print_in_color "\e[1;33m" "$*"; }
blue_bold() { print_in_color "\e[1;34m" "$*"; }
magenta_bold() { print_in_color "\e[1;35m" "$*"; }
cyan_bold() { print_in_color "\e[1;36m" "$*"; }
red_underlined() { print_in_color "\e[4;31m" "$*"; }
green_underlined() { print_in_color "\e[4;32m" "$*"; }
yellow_underlined() { print_in_color "\e[4;33m" "$*"; }
blue_underlined() { print_in_color "\e[4;34m" "$*"; }
magenta_underlined() { print_in_color "\e[4;35m" "$*"; }
cyan_underlined() { print_in_color "\e[4;36m" "$*"; }

# ==============================================================================

if [ -z "$1" ]; then
    echo "Usage: $0 <name of the song>"
    exit 1
fi

if ! [ -x "$(command -v yt-dlp)" ]; then
  red 'Error: youtube-dl is not installed. Please install it and try again.'
  exit 1
fi

if ! [ -x "$(command -v ffmpeg-normalize)" ]; then
  red 'Error: ffmpeg-normalize is not installed. Please install it and try again.'
  exit 1
fi

# ==============================================================================

echo "Searching for song '$1' and downloading it ..."

ytOutput=$(yt-dlp --ignore-config --force-overwrites --no-playlist --format "bestaudio[ext=m4a]" --default-search "ytsearch" "ytsearch:$1" -o "%(title)s.%(ext)s")

if [ $? -ne 0 ]; then
    red "Error: Could not download the song."
    exit 1
fi

echo "$ytOutput"

downloadedFile=$(echo "$ytOutput" | grep "Destination:" | cut -d ":" -f 2 | sed -e 's/^[[:space:]]*//')

if [ -z "$downloadedFile" ]; then
    red "Error: Could not find the song '$downloadedFile'."
    exit 1
fi

green "Song downloaded successfully."

echo "Normalizing song ..."

outputFile="${downloadedFile%.*}.mp3"
ffmpeg-normalize "$downloadedFile" -ext mp3 -c:a libmp3lame -b:a 128k -ar 44100 -e="-ac 1" -o "$outputFile"

if [ $? -ne 0 ]; then
    red "Error: Could not normalize the song."
    exit 1
fi

green "Song normalized successfully to '$outputFile'."

echo "Done."
