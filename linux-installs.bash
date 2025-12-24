#!/usr/bin/env bash
set -e

echo "=== Starting idempotent setup ==="

# -------- Helpers --------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

append_if_missing() {
  local LINE="$1"
  local FILE="$2"
  grep -qxF "$LINE" "$FILE" 2>/dev/null || echo "$LINE" >> "$FILE"
}

# -------- Bash config (idempotent) --------
echo "Setting up bash configuration files..."

copy_with_backup() {
  local SRC="$1"
  local DEST="$2"

  if [ ! -f "$SRC" ]; then
    echo "⚠ Source file $SRC not found, skipping"
    return
  fi

  if [ -f "$DEST" ]; then
    if cmp -s "$SRC" "$DEST"; then
      echo "✔ $DEST already up to date"
      return
    fi

    if [ ! -f "${DEST}.bak" ]; then
      echo "Backing up existing $DEST to ${DEST}.bak"
      cp "$DEST" "${DEST}.bak"
    else
      echo "✔ Backup already exists for $DEST"
    fi
  fi

  echo "Updating $DEST"
  cp "$SRC" "$DEST"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_with_backup "$SCRIPT_DIR/bashrc" "$HOME/.bashrc"
copy_with_backup "$SCRIPT_DIR/bash_aliases" "$HOME/.bash_aliases"

# -------- System packages --------
echo "Checking apt dependencies..."
sudo apt-get update -y

for pkg in build-essential curl git ncdu; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "✔ $pkg already installed"
  else
    echo "Installing $pkg..."
    sudo apt-get install -y "$pkg"
  fi
done

# -------- Homebrew --------
if command_exists brew; then
  echo "✔ Homebrew already installed"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
append_if_missing "$BREW_SHELLENV" "$HOME/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew update

# -------- Brew packages --------
install_brew_pkg() {
  if brew list "$1" >/dev/null 2>&1; then
    echo "✔ $1 already installed"
  else
    echo "Installing $1..."
    brew install "$1"
  fi
}

install_brew_pkg argocd
install_brew_pkg lazygit
install_brew_pkg terragrunt
install_brew_pkg kustomize
install_brew_pkg derailed/k9s/k9s

# -------- Terraform --------
if brew tap | grep -q "^hashicorp/tap$"; then
  echo "✔ hashicorp/tap already added"
else
  brew tap hashicorp/tap
fi

install_brew_pkg hashicorp/tap/terraform

# -------- AWS CLI --------
if command_exists aws; then
  echo "✔ AWS CLI already installed"
else
  echo "Installing AWS CLI via snap..."
  sudo snap install aws-cli --classic
fi

# -------- Cursor (WSL integration) --------
CURSOR_PATH='export PATH="$PATH:/mnt/c/Program Files/cursor/resources/app/bin"'
append_if_missing "" "$HOME/.bashrc"
append_if_missing "# Cursor" "$HOME/.bashrc"
append_if_missing "$CURSOR_PATH" "$HOME/.bashrc"

# -------- Final checks --------
echo
echo "=== Verification ==="
brew --version
brew doctor || true
terraform version || true
aws --version || true
k9s version || true
argocd version --client || true

echo
echo "=== Setup complete ==="

