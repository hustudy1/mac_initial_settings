#!/usr/bin/env bash

# install_brew.sh - macOS Homebrew installation helper
# Usage: sh install_brew.sh  (or make it executable and run directly)
#
# Installs Homebrew if not already present.  Ensures Xcode command-line
# tools are installed first, since they are often required for building
# software from source via brew.  If Homebrew is already installed, the
# script prints its location and exits.

set -euo pipefail

echo "[brew setup] starting..."

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# ensure Xcode CLI tools exist (Homebrew requires them in many cases)
if ! xcode-select -p >/dev/null 2>&1; then
    echo "Xcode command line tools not found; installing..."
    xcode-select --install
    echo "Waiting for Xcode CLI tools to finish..."
    while ! xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done
    echo "Xcode command line tools installed."
fi

if has_cmd brew; then
    echo "Homebrew already installed at $(command -v brew)"
else
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # make brew available in this shell session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        BREW_ENV="$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        BREW_ENV="$(/usr/local/bin/brew shellenv)"
    fi
    # ensure future shells also have brew in PATH
    if [[ -n "$BREW_ENV" ]]; then
        if [[ -n "$ZSH_NAME" ]]; then
            PROFILE="$HOME/.zprofile"
        else
            PROFILE="$HOME/.bash_profile"
        fi
        if ! grep -qxF "$BREW_ENV" "$PROFILE" 2>/dev/null; then
            echo "\n# added by install_brew.sh" >> "$PROFILE"
            echo "$BREW_ENV" >> "$PROFILE"
            echo "Appended Homebrew initialization to $PROFILE"
        fi
    fi
    echo "Homebrew installed."
fi

echo "[brew setup] done."
