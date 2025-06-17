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

_check_uv() {
  uv --version || { _error "uv is not installed. Install from https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }
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

_read_pyproject_version() {
  # Looks for 'version = "x.y.z"' in pyproject.toml
  grep -m 1 -E '^\\s*version\\s*=\\s*"[^"]+"' "$1" | head -n 1 | sed -E 's/^\\s*version\\s*=\\s*"([^"]+)"\\s*$/\\1/'
}

# ==============================================================================
# MAIN SCRIPT

# Initialize variables:
verbose=0
force=0
noPush=0
noPublish=0
releaseType=
projectDir=

usage() {
  echo "$0 [OPTIONS]"
  echo ""
  echo "Release Python scripts"
  echo ""
  echo "-h, --help              show this help"
  echo "-v, --verbose	          verbose"
  echo "-f, --force	            force"
  echo "-n, --no-push	          do not push to remote"
  echo "-p, --no-publish	      do not publish to PyPI"
  echo "-t, --release-type	    release type (patch, minor, major)"
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

packageName=$(basename "$(dirname "$(find . -name '__init__.py' -maxdepth 2 | head -n 1)")")
# If packageName is empty or ".", try to infer it if a pyproject.toml exists and has a name
if [[ -z "$packageName" || "$packageName" == "." ]] && [[ -f "$projectDir/pyproject.toml" ]]; then
    # Try to get package name from pyproject.toml using a simple grep and sed
    inferredName=$(grep -m 1 -E '^\\s*name\\s*=\\s*"[^"]+"' "$projectDir/pyproject.toml" | sed -E 's/^\\s*name\\s*=\\s*"([^"]+)"\\s*$/\\1/')
    if [[ -n "$inferredName" ]]; then
        packageName="$inferredName"
        _info "Inferred package name '$packageName' from pyproject.toml"
    fi
fi

if ! [[ -f setup.py ]]; then
  if [[ -f pyproject.toml ]]; then
    _info "No setup.py found. Found pyproject.toml, proceeding with PEP 517 build."
  else
    _error "Neither setup.py nor pyproject.toml found. Cannot determine how to build the package."
    exit 1
  fi
else
  if [[ -f pyproject.toml ]]; then
    _info "Found both setup.py and pyproject.toml. Build will likely use pyproject.toml."
  else
    _info "Found setup.py. Build will use it."
  fi
fi

_check_uv
_check_repo "$projectDir"
[[ "$force" -eq 1 ]] || _check_repo_status

pythonVersionFile=
pyprojectVersionFile=
currentVersion=
versionSource=

# Try to find pyproject.toml first
if [[ -f "$projectDir/pyproject.toml" ]]; then
  pyprojectVersionFile="$projectDir/pyproject.toml"
  currentVersion=$(_read_pyproject_version "$pyprojectVersionFile")
  if [[ -n "$currentVersion" ]]; then
    versionSource="pyproject.toml"
  fi
fi

# Try to find Python version file (e.g., __init__.py or _version.py)
# Search within the package directory or common locations like src/
# Prioritize a direct match in packageName if it exists, then src/packageName, then broader search
search_paths=()
if [[ -n "$packageName" && -d "$projectDir/$packageName" ]]; then
  search_paths+=("$projectDir/$packageName")
fi
if [[ -n "$packageName" && -d "$projectDir/src/$packageName" ]]; then
  search_paths+=("$projectDir/src/$packageName")
fi
search_paths+=("$projectDir/src" "$projectDir") # Broader search as fallback

foundPythonVersionFile=
for search_path in "${search_paths[@]}"; do
  if [[ -d "$search_path" ]]; then # Ensure search path exists
    foundPythonVersionFile=$(find "$search_path" -maxdepth 2 -type f -name '*.py' -exec grep -H '__version__\s*=' {} \; | head -n 1 | cut -d: -f1)
    if [[ -n "$foundPythonVersionFile" ]]; then
      break
    fi
  fi
done

if [[ -n "$foundPythonVersionFile" ]]; then
  pythonVersionFile="$foundPythonVersionFile"
  pythonFileVersion=$(_read_version "$pythonVersionFile")

  if [[ -z "$currentVersion" ]]; then # If pyproject.toml version was not found or pyproject.toml doesn't exist
    currentVersion="$pythonFileVersion"
    versionSource="Python file ($pythonVersionFile)"
  elif [[ "$currentVersion" != "$pythonFileVersion" ]]; then
    _warn "Version mismatch! pyproject.toml has $currentVersion, Python file ($pythonVersionFile) has $pythonFileVersion. Using pyproject.toml version."
    # Keep currentVersion from pyproject.toml as primary
  fi
fi

if [[ -z "$currentVersion" ]]; then
  _error "No version definition found in pyproject.toml or any Python file! Cannot proceed."
  exit 1
fi

if [[ -z "$pythonVersionFile" && -z "$pyprojectVersionFile" ]]; then
   _error "No version file found! Neither pyproject.toml nor a Python file with __version__."; exit 1
fi

if [[ -f $pyprojectVersionFile && -n "$(_read_pyproject_version $pyprojectVersionFile)" ]]; then
  _info "Found pyproject.toml with version information."
else
  # Unset pyprojectVersionFile if it doesn't contain a version or doesn't exist
  # to prevent trying to update it later if it's not a valid version source.
  pyprojectVersionFile=
fi

if [[ -f $pythonVersionFile && -n "$(_read_version $pythonVersionFile)" ]]; then
  _info "Found Python version file: $pythonVersionFile"
else
  # Unset pythonVersionFile if it doesn't actually contain a version, to prevent later errors.
  pythonVersionFile=
fi

latestHash=$(git log --pretty=format:'%h' -n 1)

echo
echo "Project directory: $(realpath "$projectDir")"
if [[ -n "$packageName" && "$packageName" != "." ]]; then
  echo "Package name:      $packageName"
fi
echo "Version read from: $versionSource"
if [[ -n "$pythonVersionFile" ]]; then
  echo "Python version file: $pythonVersionFile"
fi
if [[ -n "$pyprojectVersionFile" ]]; then
  echo "Pyproject file:    $pyprojectVersionFile"
fi
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
  # Determine which files were changed to provide accurate restore commands
  if [[ -n "$pythonVersionFile" ]]; then
    echo "git checkout -- \"$pythonVersionFile\""
  fi
  if [[ -n "$pyprojectVersionFile" ]]; then
    echo "git checkout -- \"$pyprojectVersionFile\""
  fi
  echo "git reset --hard HEAD~1" # Go back to before the bump commit
  echo "git tag -d v$newVersion"
}

# give the user some info in case of errors
trap _restore ERR

# replace the Python version if file exists and was identified
if [[ -n "$pythonVersionFile" ]]; then
  _info "Updating version in $pythonVersionFile ..."
  perl -pi -e "s/^(__version__\s*=\s*['\"])\Q$currentVersion\E(['\"])/\${1}${newVersion}\${2}/" "$pythonVersionFile"
  git add "$pythonVersionFile"
fi

# replace the pyproject version, if file exists and was identified
if [[ -n "$pyprojectVersionFile" ]]; then
  _info "Updating version in $pyprojectVersionFile ..."
  perl -pi -e "s/^(version\s*=\s*['\"])\Q$currentVersion\E(['\"])/\${1}${newVersion}\${2}/" "$pyprojectVersionFile"
  git add "$pyprojectVersionFile"
fi

# Ensure at least one file was updated before committing
if ! git diff --cached --quiet; then
  # bump initially but to not push yet
  git commit -m "Bump version to ${newVersion}"
  git tag -a -m "Tag version ${newVersion}" "v$newVersion"

  # generate the changelog
  uvx --with pystache gitchangelog > CHANGELOG.md

  # add the changelog and amend it to the previous commit and tag
  git add CHANGELOG.md
  git commit --amend --no-edit

  # generate the docs, if available
  if [[ -d docs ]]; then
    _info "Generating docs ..."
    if [[ -f mkdocs.yml ]]; then
      echo "Skipping pdoc, you should use mkdocs to generate the docs"
    else
      doc_target_module="."
      if [[ -n "$packageName" && "$packageName" != "." && -d "./$packageName" ]]; then
        doc_target_module="./$packageName"
      fi
      _info "Using '$doc_target_module' as pdoc target module."
      if [[ -f requirements.txt ]]; then
        uvx --with-requirements requirements.txt pdoc -d google -o docs "$doc_target_module"
      else
        _warn "No requirements.txt found, using pdoc without requirements, this may fail!"
        uvx pdoc -d google -o docs "$doc_target_module" || {
          _error "pdoc failed, please check the requirements.txt file. Continuing anyway ..."
        }
      fi
      git add docs
    fi
    git commit --amend --no-edit
  else
    _info "No docs directory found, skipping ... (if you want to generate docs, create an empty docs directory first)"
  fi

  git tag -a -f -m "Tag version ${newVersion}" "v$newVersion"
else
  _warn "No version files were updated. Skipping commit and tag."
fi

rm -rf dist/* build
_info "Building package ..."
rm -rf dist/* tar.gz
rm -rf dist/* whl
python3 -m build --wheel

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
  uvx twine upload dist/*
fi

_info "Finished!"
