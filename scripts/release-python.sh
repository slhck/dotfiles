#!/usr/bin/env bash
#
# Semi-automatic release script for Python projects
#
# Requirements:
# - `uv`
# - Optional:
# - `gh` CLI for GitHub releases (https://cli.github.com/)
# - `git-cliff` for better changelog generation (https://git-cliff.org/), will fall back to gitchangelog
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

_check_uv() {
  uv --version || { _error "uv is not installed. Install from https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }
}

_check_gh_and_git_cliff() {
  if command -v gh git-cliff &> /dev/null; then
    return 0
  else
    return 1
  fi
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

# ==============================================================================
# MAIN SCRIPT

# Initialize variables:
verbose=0
force=0
noPush=0
noPublish=0
noGithubRelease=0
initial=0
releaseType=
projectDir=
FORCE=false

usage() {
  echo "$0 [OPTIONS]"
  echo ""
  echo "Release Python scripts"
  echo ""
  echo "-h, --help               show this help"
  echo "-v, --verbose            verbose"
  echo "-f, --force              force"
  echo "-i, --initial            initial release (use current version, no bump)"
  echo "-n, --no-push            do not push to remote"
  echo "-p, --no-publish         do not publish to PyPI"
  echo "-g, --no-github-release  do not create a GitHub release"
  echo "-t, --release-type       release type (patch, minor, major)"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        -f|--force)
            force=1
            FORCE=true
            shift
            ;;
        -n|--no-push)
            noPush=1
            shift
            ;;
        -p|--no-publish)
            noPublish=1
            shift
            ;;
        -g|--no-github-release)
            noGithubRelease=1
            shift
            ;;
        -i|--initial)
            initial=1
            shift
            ;;
        -t|--release-type)
            releaseType="$2"
            shift 2
            ;;
        *)
            break
            ;;
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

# Check if pyproject.toml exists
if ! [[ -f pyproject.toml ]]; then
  _error "No pyproject.toml found. This script now requires pyproject.toml for version management."
  exit 1
fi

_check_uv
_check_repo "$projectDir"
[[ "$force" -eq 1 ]] || _check_repo_status

# Get current version from uv
currentVersion=$(uv version --short) || { _error "Failed to get version from uv. Is this a valid Python project with pyproject.toml?"; exit 1; }

# Get package name from pyproject.toml
packageName=$(grep -m 1 -E '^[[:space:]]*name[[:space:]]*=' pyproject.toml | sed -E 's/^[[:space:]]*name[[:space:]]*=[[:space:]]*"([^"]+)".*$/\1/')

# Debug: check if extraction worked
if [[ -z "$packageName" ]]; then
  _error "Could not extract package name from pyproject.toml"
  exit 1
fi

# Convert package name to module name (replace hyphens with underscores)
moduleName=$(echo "$packageName" | tr '-' '_')

latestHash=$(git log --pretty=format:'%h' -n 1)

echo
echo "Project directory: $(realpath "$projectDir")"
if [[ -n "$packageName" ]]; then
  echo "Package name:      $packageName"
fi
if [[ -n "$moduleName" && "$moduleName" != "$packageName" ]]; then
  echo "Module name:       $moduleName"
fi
echo "Repo hash:         $latestHash"
echo "Current version:   $currentVersion"

# ==============================================================================
# RELEASE VERSION

if [[ $initial -eq 1 ]]; then
  # Check if tags already exist
  if git describe --tags --abbrev=0 2>/dev/null; then
    _error "Tags already exist. Use --initial only for the first release."
    exit 1
  fi
  _info "Initial release: using current version $currentVersion"
  newVersion="$currentVersion"
else
  if [[ -z $releaseType ]]; then
    echo
    _question "Which type of release?"
    PS3="Release type: "
    select releaseType in major minor patch; do break; done
  else
    _info "Release type chosen: $releaseType"
  fi

  # Show what the new version would be
  echo
  _info "Would bump version:"
  uv version --bump "$releaseType" --dry-run
fi

# ==============================================================================
# THE RELEASE ITSELF

# Prompt for confirmation
if [ "$FORCE" = false ]; then
  echo
  read -p "Do you want to release? [yY] " -n 1 -r
  echo
else
  REPLY="y"
fi
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [[ $initial -eq 1 ]]; then
    # Initial release: create tag first, then changelog
    git tag -a "v$newVersion" -m "v$newVersion"

    # Generate changelog
    if command -v git-cliff &> /dev/null; then
      git-cliff > CHANGELOG.md 2> /dev/null
    else
      _warn "git-cliff not found. Falling back to slower gitchangelog!"
      uvx --with pystache gitchangelog > CHANGELOG.md
    fi

    git add CHANGELOG.md
    git commit -m "chore: add CHANGELOG.md for v$newVersion"
    git tag -a -f -m "v$newVersion" "v$newVersion"
  else
    # Bump version using uv
    uv version --bump "$releaseType"

    # Get the new version
    newVersion=$(uv version --short)

    # Commit changes
    git add pyproject.toml uv.lock
    git commit -m "chore: bump version to $newVersion"
    git tag -a "v$newVersion" -m "v$newVersion"

    # Generate changelog
    if command -v git-cliff &> /dev/null; then
      git-cliff > CHANGELOG.md 2> /dev/null
    else
      _warn "git-cliff not found. Falling back to slower gitchangelog!"
      uvx --with pystache gitchangelog > CHANGELOG.md
    fi

    git add CHANGELOG.md
    git commit --no-verify --amend --no-edit
    git tag -a -f -m "v$newVersion" "v$newVersion"
  fi

  # Generate the docs, if available
  if [[ -d docs ]]; then
    _info "Generating docs ..."
    if [[ -f mkdocs.yml ]]; then
      echo "Skipping pdoc, you should use mkdocs to generate the docs"
    else
      # For modernized projects with src layout
      doc_target_module=""
      if [[ -d "src/$moduleName" ]]; then
        doc_target_module="src/$moduleName"
      elif [[ -d "src/$packageName" ]]; then
        doc_target_module="src/$packageName"
      elif [[ -d "$moduleName" ]]; then
        doc_target_module="$moduleName"
      elif [[ -d "$packageName" ]]; then
        doc_target_module="$packageName"
      fi

      # If we couldn't find a specific module directory, skip pdoc
      if [[ -z "$doc_target_module" ]]; then
        _warn "Could not find module directory for package '$packageName' (tried src/$moduleName, src/$packageName, $moduleName, $packageName)"
        _warn "Skipping pdoc documentation generation"
      else
        _info "Using '$doc_target_module' as pdoc target module."

        # Use uv to run pdoc with the project dependencies
        uv run pdoc -d google -o docs "$doc_target_module" || {
          _error "pdoc failed. Continuing anyway ..."
        }

        git add docs
        git commit --no-verify --amend --no-edit
        git tag -a -f -m "v$newVersion" "v$newVersion"
      fi
    fi
  else
    _info "No docs directory found, skipping ... (if you want to generate docs, create an empty docs directory first)"
  fi
else
  _info "Aborted."
  exit 1
fi

# Build package
rm -rf dist/* build
_info "Building package ..."
uv build

if [[ $noPush -eq 1 ]]; then
  _warn "Skipping push!"
else
  # Get the current branch name
  currentBranch=$(git branch --show-current)

  # Push to Git
  _info "Pushing to remote ..."
  git push origin "$currentBranch"
  git push origin "v$newVersion"

  # Create GitHub release if gh is available.
  # We needw git-cliff too because gitchangelog's filtering is not intuitive.
  if [[ $noGithubRelease -eq 1 ]]; then
    _warn "Skipping GitHub release!"
  elif _check_gh_and_git_cliff; then
    _info "Creating GitHub release ..."

    # Generate release notes
    # First, get the previous tag
    prevTag=$(git describe --tags --abbrev=0 "v$newVersion^" 2>/dev/null || echo "")

    # Try git-cliff first for more control
    if [[ -n "$prevTag" ]]; then
      releaseNotes=$(git-cliff --strip all "$prevTag..v$newVersion" 2>/dev/null)
    else
      releaseNotes=$(git-cliff --strip all --latest 2>/dev/null)
    fi

    # Create the release with assets
    if [[ -n "$(ls -A dist 2>/dev/null)" ]]; then
      echo "$releaseNotes" | gh release create "v$newVersion" \
        --title "v$newVersion" \
        --notes-file - \
        dist/*
    else
      echo "$releaseNotes" | gh release create "v$newVersion" \
        --title "v$newVersion" \
        --notes-file -
    fi

    if [[ $? -eq 0 ]]; then
      _info "GitHub release created successfully!"
    else
      _warn "Failed to create GitHub release. Continuing anyway..."
    fi
  else
    _warn "gh CLI or git-cliff not found. Skipping GitHub release creation."
    _info "Install gh from: https://cli.github.com/"
    _info "Install git-cliff from: https://git-cliff.org/"
  fi
fi

if [[ $noPublish -eq 1 ]]; then
  _warn "Skipping publish!"
else
  # upload to PyPi
  _info "Pushing to PyPI ..."
  uvx twine upload dist/*
fi

_info "Finished!"
