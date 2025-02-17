#!/usr/bin/env bash
#
# Semi-automatic release script for Python projects
#
# Requirements:
# - `pip3 install wheel twine gitchangelog`
#
# Author: Werner Robitza

set -e

# ==============================================================================
# PRINTING STUFF

RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
RESET="\033[0m"

QUESTION_FLAG="❔"
WARNING_FLAG="❕"
ERROR_FLAG="🛑"
NOTICE_FLAG="❯"

# ==============================================================================
# FUNCTIONS

_warn() {
  echo -e "$YELLOW$WARNING_FLAG $1$RESET"
}

_info() {
  echo -e "$WHITE$NOTICE_FLAG $1$RESET"
}

_question() {
  echo -e "$GREEN$QUESTION_FLAG  $1$RESET"
}

_error() {
  echo -e "$RED$ERROR_FLAG $1$RESET"
}

_check_packages() {
  for package in pypandoc twine wheel gitchangelog pystache pdoc; do
    python -c "import ${package}" || \
      { _error "${package} is not installed. Install via pip!"; exit 1; }
  done
}

_check_repo() {
  [[ -d "$1/.git" ]] || \
    { _error "Project directory $projectDir is not a Git repo!"; exit 1; }
}

_check_repo_status() {
  [[ -z $(git status -s) ]] || \
    { _error "repo is not clean, commit everything first!"; exit 1; }

  # https://stackoverflow.com/a/25109122/435093
  _info "Fetching remote changes ..."
  git fetch --all
  [[ "$(git rev-parse HEAD)" == "$(git rev-parse @{u})" ]] || \
    { _error "Git repo not up to date! Pull/merge first."; exit 1; }
}

_read_version() {
  grep "__version__ =" "$1" | head -n 1 | cut -d '=' -f 2 | tr -d '"' | tr -d "'" | tr -d ' '
}

_incrementVersion() {
  # https://stackoverflow.com/a/64390598/435093
  local array=($(echo "$1" | tr . '\n'))
  array[$2]=$((array[$2]+1))
  if [ $2 -lt 2 ]; then array[2]=0; fi
  if [ $2 -lt 1 ]; then array[1]=0; fi
  echo "$(local IFS=. ; echo "${array[*]}")"
}

# ==============================================================================
# MAIN SCRIPT

# Initialize variables:
verbose=0
force=0
noPush=0
noPublish=0
releaseType=

usage() {
  echo "$0 [-hvfn]"
  echo ""
  echo "Release Python scripts"
  echo ""
  echo "-h	show help"
  echo "-v	verbose"
  echo "-n	do not push to remote"
  echo "-p  do not publish to PyPI"
  echo "-t	release type (patch, minor, major)"
}

while getopts "h?vfnpt:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0;;
    v)  verbose=1;;
    f)  force=1;;
    n)  noPush=1;;
    p)  noPublish=1;;
    t)  releaseType="$OPTARG";;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

if [[ $# -eq 1 ]]; then
  projectDir=$(realpath "$1")
else
  projectDir=$(pwd)
fi

cd "$projectDir" || exit 1

packageName=$(basename "$(dirname "$(find . -name '__init__.py' -maxdepth 2 | head -n 1)")")

_check_packages
_check_repo "$projectDir"
[[ "$force" -eq 1 ]] || _check_repo_status

pythonVersionFile=$(grep -l --include \*.py -r '__version__ =' "$packageName" | head -n 1)
pyprojectVersionFile=pyproject.toml

if [[ -z $pythonVersionFile ]]; then
  _error "No version file found!"; exit 1
fi

if [[ -f $pyprojectVersionFile ]]; then
  _info "Found pyproject.toml file in addition to Python version file!"
else
  pyprojectVersionFile=
fi

latestHash=$(git log --pretty=format:'%h' -n 1)
currentVersion=$(_read_version "$pythonVersionFile")

echo
echo "Project directory: $(realpath "$projectDir")"
echo "Package name:      $packageName"
echo "Version file:      $pythonVersionFile"
echo "Pyproject file:    $pyprojectVersionFile"
echo "Repo hash:         $latestHash"
echo "Current version:   $currentVersion"

# ==============================================================================
# RELEASE VERSION

if [[ -z $releaseType ]]; then
  echo
  _question "Which type of release?"
  PS3="Release type: "
  select releaseType in major minor patch; do break; done
else
  _info "Release type chosen: $releaseType"
fi

separators=$(tr -dc '.' <<< "$currentVersion" | wc -c)
if [[ $separators -eq 1 ]]; then
  if [[ $releaseType = "patch" ]]; then position=1;
  elif [[ $releaseType = "minor" ]]; then position=1;
  elif [[ $releaseType = "major" ]]; then position=0;
  else _error "Wrong release type!"; exit 1;
  fi
elif [[ $separators -eq 2 ]]; then
  if [[ $releaseType = "patch" ]]; then position=2;
  elif [[ $releaseType = "minor" ]]; then position=1;
  elif [[ $releaseType = "major" ]]; then position=0;
  else _error "Wrong release type!"; exit 1;
  fi
else
  _warn "Could not parse separators from version: $currentVersion"; exit 1
fi

newVersion=$(_incrementVersion "$currentVersion" "$position")

_info "Setting new version to: $newVersion"

# ==============================================================================
# THE RELEASE ITSELF

_restore() {
  _warn "To restore, run something like:"
  echo "cd '$projectDir'"
  echo "git reset --hard origin/master"
  echo "git tag -d v$newVersion"
}

# give the user some info in case of errors
trap _restore ERR

# replace the Python version
perl -pi -e "s/\Q$currentVersion\E/$newVersion/" "$pythonVersionFile"
git add "$pythonVersionFile"

# replace the pyproject version, if applicable
if [[ -n $pyprojectVersionFile ]]; then
  perl -pi -e "s/\Q$currentVersion\E/$newVersion/" "$pyprojectVersionFile"
  git add "$pyprojectVersionFile"
fi

# bump initially but to not push yet
git commit -m "Bump version to ${newVersion}"
git tag -a -m "Tag version ${newVersion}" "v$newVersion"

# generate the changelog
gitchangelog > CHANGELOG.md

# add the changelog and amend it to the previous commit and tag
git add CHANGELOG.md
git commit --amend --no-edit

# generate the docs, if available
if [[ -d docs ]]; then
  _info "Generating docs ..."
  if [[ -f mkdocs.yml ]]; then
    echo "Skipping pdoc, you should use mkdocs to generate the docs"
  else
    pdoc -d google -o docs "./$packageName"
    git add docs
  fi
  git commit --amend --no-edit
else
  _info "No docs directory found, skipping ... (if you want to generate docs, create an empty docs directory first)"
fi

git tag -a -f -m "Tag version ${newVersion}" "v$newVersion"

rm -rf dist/* build
_info "Building package ..."
python3 setup.py sdist bdist_wheel

if [[ $noPush -eq 1 ]]; then
  _warn "Skipping push!"
else
  # Push to Git
  _info "Pushing to remote ..."
  git push && git push --tags
fi

if [[ $noPublish -eq 1 ]]; then
  _warn "Skipping publish!"
else
  # upload to PyPi
  _info "Pushing to PyPI ..."
  python3 -m twine upload dist/*
fi

_info "Finished!"
