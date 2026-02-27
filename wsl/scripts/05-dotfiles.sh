#!/usr/bin/env bash
# =============================================================================
# 05-dotfiles.sh — Symlink dotfiles from repo into $HOME
# =============================================================================
# - Backs up any existing file/symlink that is NOT already pointing here
# - Idempotent: re-running is safe
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
info() { echo -e "${CYAN}[dotfiles] $1${RESET}"; }
ok()   { echo -e "${GREEN}[dotfiles] $1${RESET}"; }
warn() { echo -e "${YELLOW}[dotfiles] $1${RESET}"; }

# Resolve the dotfiles directory relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../dotfiles" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

info "Dotfiles source : $DOTFILES_DIR"
info "Backup dir      : $BACKUP_DIR"
echo ""

# ---------------------------------------------------------------------------
# symlink_file <source_in_dotfiles_dir> <target_in_home>
# ---------------------------------------------------------------------------
symlink_file() {
  local src="$DOTFILES_DIR/$1"
  local dst="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    warn "Source not found, skipping: $src"
    return
  fi

  # Already a symlink pointing to the right place → nothing to do
  if [[ -L "$dst" ]] && [[ "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    ok "Already linked: ~/$2"
    return
  fi

  # Existing file/symlink that differs → back it up
  if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    warn "Backing up existing ~/$2 → $BACKUP_DIR/$2"
    mv "$dst" "$BACKUP_DIR/$2"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dst")"

  ln -sf "$src" "$dst"
  ok "Linked: ~/$2 → $src"
}

# ---------------------------------------------------------------------------
# Link each dotfile
# ---------------------------------------------------------------------------
symlink_file ".zshrc"     ".zshrc"
symlink_file ".p10k.zsh"  ".p10k.zsh"
symlink_file ".gitconfig" ".gitconfig"
symlink_file ".aliases"   ".aliases"

ok "Dotfiles symlinked."

# ---------------------------------------------------------------------------
# Configure git user identity (prompt only if not already set)
# ---------------------------------------------------------------------------
echo ""
info "Checking git user identity..."

GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
  ok "Git identity already configured:"
  echo "     name : $GIT_NAME"
  echo "     email: $GIT_EMAIL"
else
  echo ""
  echo -e "  ${CYAN}Git user identity is not configured yet.${RESET}"
  echo "  This will be written to your global git config (~/.gitconfig)."
  echo ""

  if [[ -z "$GIT_NAME" ]]; then
    while true; do
      printf "  Enter your git name  : "
      read -r GIT_NAME
      [[ -n "$GIT_NAME" ]] && break
      warn "Name cannot be empty."
    done
  else
    info "Git name already set: $GIT_NAME"
  fi

  if [[ -z "$GIT_EMAIL" ]]; then
    while true; do
      printf "  Enter your git email : "
      read -r GIT_EMAIL
      # basic format check
      if [[ "$GIT_EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
        break
      fi
      warn "Please enter a valid email address."
    done
  else
    info "Git email already set: $GIT_EMAIL"
  fi

  git config --global user.name  "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  ok "Git identity saved:"
  echo "     name : $GIT_NAME"
  echo "     email: $GIT_EMAIL"
fi

# Show a summary of what HOME now points to
echo ""
info "Current symlink state:"
for f in .zshrc .p10k.zsh .gitconfig .aliases; do
  if [[ -L "$HOME/$f" ]]; then
    echo "  $f  →  $(readlink "$HOME/$f")"
  fi
done
