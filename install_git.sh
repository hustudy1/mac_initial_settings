#!/usr/bin/env bash

# install_git.sh - macOS Git installation helper
# Usage: sh install_git.sh  (or make it executable and run directly)
# This script installs Git on a Mac environment, making sure Xcode
# command‑line tools and Homebrew are available.  If Git is already
# present it prints the version and exits.

set -euo pipefail

echo "[git setup] starting..."

# function to check command presence
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

if has_cmd git; then
    echo "Git already installed: $(git --version)"
else
    echo "Git not found. Proceeding with installation."

    # install Xcode command line tools if needed
    if ! xcode-select -p >/dev/null 2>&1; then
        echo "Installing Xcode command line tools (required for Git)..."
        xcode-select --install
        echo "Waiting for Xcode CLI tools to finish..."
        while ! xcode-select -p >/dev/null 2>&1; do
            sleep 5
        done
        echo "Xcode command line tools installed."
    fi

    # install Homebrew if necessary
    if ! has_cmd brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # set up brew environment for this shell
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo "Homebrew installed."
    fi

    echo "Installing Git using Homebrew..."
    brew update
    brew install git
fi

echo "Final git version: $(git --version)"

echo "[git setup] done."
