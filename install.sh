#!/bin/bash

set -e

echo "Starting installation of portal..."

if ! command -v bun &> /dev/null; then
    echo "Bun is not installed. Attempting to install Bun..."
    curl -fsSL https://bun.sh/install | bash
    if ! command -v bun &> /dev/null; then
        echo "Failed to install Bun. Please install Bun manually to proceed."
        echo "You can install Bun from https://bun.sh/docs/installation"
        exit 1
    fi
fi

echo "Bun is installed. Proceeding with installation."

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"

echo "Installing project dependencies with Bun..."
bun install

echo "Building the portal binary..."
bun run build

INSTALL_PATH="/usr/local/bin"

echo "Moving portal to $INSTALL_PATH..."
sudo mv portal "$INSTALL_PATH/"

echo "Installation complete!"
echo ""
echo "You can now run 'portal' from anywhere."
echo "Usage: portal [path/to/your/portal.yaml]"
echo "If no path is provided, it will look for 'portal.yaml' in the current directory."
