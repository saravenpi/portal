#!/bin/bash

set -e

echo "Starting installation of portal..."

REPO_URL="https://github.com/saravenpi/portal.git"
BIN_PATH="/usr/local/bin/portal"

# Check if portal is already installed
if [ -f "$BIN_PATH" ]; then
  read -p "Portal is already installed. Do you want to update it? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Update cancelled. Exiting."
    exit 0
  fi
fi

# Check if Bun is installed
if ! command -v bun &>/dev/null; then
  echo "Bun is not installed. Attempting to install Bun..."
  curl -fsSL https://bun.sh/install | bash
  if ! command -v bun &>/dev/null; then
    echo "Failed to install Bun. Please install Bun manually to proceed."
    echo "You can install Bun from https://bun.sh/docs/installation"
    exit 1
  fi
fi

echo "Bun is installed. Proceeding with installation."

# Create a temporary directory for cloning and building
TMP_DIR=$(mktemp -d -t portal-install-XXXXXXXXXX)
echo "Using temporary directory: $TMP_DIR"

# Clone the repository into the temporary directory
echo "Cloning portal repository into $TMP_DIR..."
git clone "$REPO_URL" "$TMP_DIR"
cd "$TMP_DIR"

echo "Installing project dependencies with Bun..."
bun install

echo "Building the portal binary..."
bun run build

echo "Moving portal to /usr/local/bin/ ..."
sudo mv "$TMP_DIR/portal" "/usr/local/bin/"

# Clean up the temporary directory
echo "Cleaning up temporary directory..."
rm -rf "$TMP_DIR"

echo "Installation complete!"
echo ""
echo "You can now run 'portal' from anywhere."
echo "Usage: portal [path/to/your/portal.yaml]"
echo "If no path is provided, it will look for 'portal.yaml' in the current directory."
