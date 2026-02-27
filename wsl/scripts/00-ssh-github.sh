#!/usr/bin/env bash
# =============================================================================
# 00-ssh-github.sh — Generate SSH key and register it with GitHub
# =============================================================================
# Run this BEFORE cloning the repo on a fresh machine.
#
# Can be run directly from GitHub without cloning first:
#   bash <(curl -fsSL https://raw.githubusercontent.com/k1v/dev-setup/master/wsl/scripts/00-ssh-github.sh)
#
# What it does:
#   1. Installs git and curl if missing
#   2. Generates an ed25519 SSH key (skips if one already exists)
#   3. Tests SSH connection to GitHub — if already working, skips key registration
#      Otherwise: prints the public key, waits for you to add it to GitHub, re-tests
#   4. Clones the dev-setup repo (skips if already cloned)
#   5. Runs bootstrap.sh
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RED='\033[0;31m'; RESET='\033[0m'
info() { echo -e "${CYAN}[ssh-github] $1${RESET}"; }
ok()   { echo -e "${GREEN}[ssh-github] $1${RESET}"; }
warn() { echo -e "${YELLOW}[ssh-github] $1${RESET}"; }
die()  { echo -e "${RED}[ssh-github] ERROR: $1${RESET}"; exit 1; }

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
# 2. Generate SSH key if one doesn't exist
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ -f "$SSH_KEY" ]]; then
  ok "SSH key already exists: $SSH_KEY"
else
  # Prompt for email to embed in the key comment
  while true; do
    printf "\n  Enter your GitHub email address: "
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

# ---------------------------------------------------------------------------
# 3. Test SSH connection — if already working, skip the display/prompt
# ---------------------------------------------------------------------------
info "Testing SSH connection to github.com..."
SSH_OUTPUT=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)

if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
  GITHUB_USER=$(echo "$SSH_OUTPUT" | grep -o 'Hi [^!]*' | cut -d' ' -f2)
  ok "SSH already authenticated as: $GITHUB_USER — skipping key registration step"
else
  # ---------------------------------------------------------------------------
  # SSH not working yet — display public key and prompt user to add it
  # ---------------------------------------------------------------------------
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

  # Re-test after user confirms
  SSH_OUTPUT=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
  if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
    GITHUB_USER=$(echo "$SSH_OUTPUT" | grep -o 'Hi [^!]*' | cut -d' ' -f2)
    ok "SSH connection successful — authenticated as: $GITHUB_USER"
  else
    echo "$SSH_OUTPUT"
    die "SSH connection to GitHub failed. Check that the key was added correctly and try again."
  fi
fi

# ---------------------------------------------------------------------------
# 5. Clone dev-setup and run bootstrap
# ---------------------------------------------------------------------------
if [[ -d "$REPO_CLONE_DIR" ]]; then
  ok "Repo already cloned at $REPO_CLONE_DIR — skipping clone"
else
  info "Cloning dev-setup repo..."
  mkdir -p "$HOME/repos"
  git clone "$REPO_SSH" "$REPO_CLONE_DIR"
  ok "Cloned to $REPO_CLONE_DIR"
fi

echo ""
info "Launching bootstrap..."
echo ""
bash "$REPO_CLONE_DIR/wsl/bootstrap.sh" "$@"
