#!/usr/bin/env bash
# =============================================================================
# 00-ssh-github.sh — Bootstrap a fresh WSL machine
# =============================================================================
# Run this BEFORE cloning the repo on a fresh machine:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/k1v/dev-setup/main/wsl/scripts/00-ssh-github.sh)
#
# What it does:
#   1. Installs git and curl if missing
#   2. Asks whether to set up an SSH key for GitHub (explains why/when useful)
#      - Yes: generates ed25519 key, walks through adding it to GitHub
#      - No:  skips — you can always run this script again later
#   3. Clones the dev-setup repo (HTTPS or SSH depending on choice above)
#   4. Runs bootstrap.sh
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RED='\033[0;31m'; RESET='\033[0m'
info() { echo -e "${CYAN}[bootstrap] $1${RESET}"; }
ok()   { echo -e "${GREEN}[bootstrap] $1${RESET}"; }
warn() { echo -e "${YELLOW}[bootstrap] $1${RESET}"; }
die()  { echo -e "${RED}[bootstrap] ERROR: $1${RESET}"; exit 1; }

REPO_HTTPS="https://github.com/k1v/dev-setup.git"
REPO_SSH="git@github.com:k1v/dev-setup.git"
REPO_CLONE_DIR="$HOME/repos/dev-setup"
SSH_KEY="$HOME/.ssh/id_ed25519"

# ---------------------------------------------------------------------------
# 1. Ensure git and curl are available
# ---------------------------------------------------------------------------
if ! command -v git &>/dev/null || ! command -v curl &>/dev/null; then
  info "Installing git and curl..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq git curl
fi

# ---------------------------------------------------------------------------
# 2. Ask about SSH key setup
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  SSH key setup for GitHub${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo "  This repo is public, so cloning works without an SSH key."
echo "  However, an SSH key is useful if you want to:"
echo ""
echo "    - Push commits back to the repo from WSL (e.g. dotfile changes)"
echo "    - Clone or push to any of your private GitHub repos"
echo "    - Avoid typing your GitHub password for every git operation"
echo ""
echo "  You can skip this now and set it up later by re-running this script."
echo ""

USE_SSH=""
while [[ "$USE_SSH" != "y" && "$USE_SSH" != "n" ]]; do
  printf "  Set up SSH key for GitHub? [y/N]: "
  read -r USE_SSH
  USE_SSH="${USE_SSH:-n}"
  USE_SSH="${USE_SSH,,}"  # lowercase
done

echo ""

if [[ "$USE_SSH" == "y" ]]; then
  # -------------------------------------------------------------------------
  # SSH key generation
  # -------------------------------------------------------------------------
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ -f "$SSH_KEY" ]]; then
    ok "SSH key already exists: $SSH_KEY"
  else
    while true; do
      printf "  Enter your GitHub email address: "
      read -r KEY_EMAIL
      [[ "$KEY_EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]] && break
      warn "Please enter a valid email address."
    done

    info "Generating ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "$KEY_EMAIL" -f "$SSH_KEY" -N ""
    ok "SSH key generated: $SSH_KEY"
  fi

  # Start ssh-agent and add the key
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add "$SSH_KEY" 2>/dev/null

  # Test connection — if already working, skip the display/prompt
  info "Testing SSH connection to github.com..."
  SSH_OUTPUT=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)

  if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
    GITHUB_USER=$(echo "$SSH_OUTPUT" | grep -o 'Hi [^!]*' | cut -d' ' -f2)
    ok "Already authenticated as: $GITHUB_USER — skipping key registration"
  else
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}  Add this SSH key to your GitHub account${RESET}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${CYAN}Your public key:${RESET}"
    echo ""
    cat "${SSH_KEY}.pub"
    echo ""
    echo "  Steps:"
    echo "  1. Copy the key above"
    echo "  2. Go to: https://github.com/settings/ssh/new"
    echo "  3. Title: e.g. 'WSL $(hostname)'"
    echo "  4. Key type: Authentication Key"
    echo "  5. Paste the key and click 'Add SSH key'"
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    printf "  Press Enter once you have added the key to GitHub..."
    read -r

    SSH_OUTPUT=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
    if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
      GITHUB_USER=$(echo "$SSH_OUTPUT" | grep -o 'Hi [^!]*' | cut -d' ' -f2)
      ok "SSH connection successful — authenticated as: $GITHUB_USER"
    else
      echo "$SSH_OUTPUT"
      die "SSH connection to GitHub failed. Check that the key was added correctly and try again."
    fi
  fi

  CLONE_URL="$REPO_SSH"
else
  ok "Skipping SSH setup — will clone via HTTPS"
  CLONE_URL="$REPO_HTTPS"
fi

# ---------------------------------------------------------------------------
# 3. Clone dev-setup (or pull latest if already cloned)
# ---------------------------------------------------------------------------
if [[ -d "$REPO_CLONE_DIR/.git" ]]; then
  ok "Repo already cloned — pulling latest changes..."
  git -C "$REPO_CLONE_DIR" pull
else
  info "Cloning dev-setup repo..."
  mkdir -p "$HOME/repos"
  git clone "$CLONE_URL" "$REPO_CLONE_DIR"
  ok "Cloned to $REPO_CLONE_DIR"
fi

echo ""
info "Launching bootstrap..."
echo ""
bash "$REPO_CLONE_DIR/wsl/bootstrap.sh" "$@"
