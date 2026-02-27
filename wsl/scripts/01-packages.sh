#!/usr/bin/env bash
# =============================================================================
# 01-packages.sh — System packages + modern CLI tools
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RESET='\033[0m'
info() { echo -e "${CYAN}[packages] $1${RESET}"; }
ok()   { echo -e "${GREEN}[packages] $1${RESET}"; }

# ---------------------------------------------------------------------------
# Core apt packages
# ---------------------------------------------------------------------------
CORE_PACKAGES=(
  # Build essentials
  build-essential
  pkg-config
  # Shell
  zsh
  # Network / download
  curl
  wget
  ca-certificates
  gnupg
  # Utilities
  git
  unzip
  zip
  file
  tree
  jq
  # Process / system
  htop
  lsof
  # Text
  vim
  # Autojump
  autojump
)

# Modern CLI tools available via apt
CLI_PACKAGES=(
  fzf           # fuzzy finder
  ripgrep       # fast grep replacement (rg)
  fd-find       # fast find replacement (fdfind → fd)
  bat           # cat with syntax highlighting (batcat → bat)
)

info "Updating apt..."
sudo apt-get update -qq

info "Upgrading existing packages..."
sudo apt-get upgrade -y -qq

info "Installing core packages..."
sudo apt-get install -y -qq "${CORE_PACKAGES[@]}"

info "Installing modern CLI tools..."
sudo apt-get install -y -qq "${CLI_PACKAGES[@]}"

# ---------------------------------------------------------------------------
# eza — modern ls replacement (not in default apt on older Ubuntu)
# Install via official deb repo
# ---------------------------------------------------------------------------
if ! command -v eza &>/dev/null; then
  info "Installing eza (modern ls)..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update -qq
  sudo apt-get install -y -qq eza
else
  ok "eza already installed — skipping"
fi

# ---------------------------------------------------------------------------
# GitHub CLI (gh) — official apt repo
# ---------------------------------------------------------------------------
if ! command -v gh &>/dev/null; then
  info "Installing GitHub CLI (gh)..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq gh
  ok "GitHub CLI installed: $(gh --version | head -1)"
else
  ok "GitHub CLI already installed — skipping ($(gh --version | head -1))"
fi

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  info "Creating 'fd' symlink for fdfind..."
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  info "Creating 'bat' symlink for batcat..."
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

ok "All packages installed."
