#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — WSL Dev Environment Setup
# =============================================================================
# Usage:
#   ./bootstrap.sh            # Run all core steps
#   ./bootstrap.sh --devops   # Also install DevOps tools (kubectl, helm, etc.)
#   ./bootstrap.sh --step 02  # Run a single numbered step
#
# Idempotent: safe to re-run at any time.
#
# First time on a fresh machine (private repo)?
#   Run 00-ssh-github.sh first — it sets up SSH auth and calls this script:
#   bash <(curl -fsSL https://raw.githubusercontent.com/k1v/dev-setup/master/wsl/scripts/00-ssh-github.sh)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Ensure all scripts are executable (so the user doesn't have to chmod manually)
chmod +x "$SCRIPT_DIR/bootstrap.sh" "$SCRIPTS_DIR"/*.sh

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

DEVOPS=false
SINGLE_STEP=""

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --devops)   DEVOPS=true ;;
    --step)     SINGLE_STEP="$2"; shift ;;
    -h|--help)
      echo "Usage: $0 [--devops] [--step <NN>]"
      echo ""
      echo "  --devops        Also install DevOps tools (kubectl, helm, terraform, azure-cli)"
      echo "  --step <NN>     Run only script NN (e.g. --step 02)"
      exit 0
      ;;
    *) echo -e "${RED}Unknown option: $1${RESET}"; exit 1 ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log_header() {
  echo ""
  echo -e "${CYAN}${BOLD}============================================================${RESET}"
  echo -e "${CYAN}${BOLD}  $1${RESET}"
  echo -e "${CYAN}${BOLD}============================================================${RESET}"
}

log_step() {
  echo -e "${YELLOW}---> $1${RESET}"
}

log_ok() {
  echo -e "${GREEN}[OK] $1${RESET}"
}

log_skip() {
  echo -e "     ${BOLD}[SKIP]${RESET} $1"
}

run_script() {
  local script="$SCRIPTS_DIR/$1"
  if [[ ! -f "$script" ]]; then
    echo -e "${RED}Script not found: $script${RESET}"
    exit 1
  fi
  log_step "Running $1"
  bash "$script"
  log_ok "Completed $1"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
log_header "WSL Dev Environment Bootstrap"
echo "  Script dir : $SCRIPT_DIR"
echo "  DevOps     : $DEVOPS"
echo "  Single step: ${SINGLE_STEP:-none}"
echo ""

if [[ -n "$SINGLE_STEP" ]]; then
  # Find matching script
  match=$(ls "$SCRIPTS_DIR"/${SINGLE_STEP}*.sh 2>/dev/null | head -1)
  if [[ -z "$match" ]]; then
    echo -e "${RED}No script found matching step '${SINGLE_STEP}'${RESET}"
    exit 1
  fi
  run_script "$(basename "$match")"
  echo ""
  log_ok "Single step done."
  exit 0
fi

# Full run
run_script "01-packages.sh"
run_script "02-zsh.sh"
run_script "03-fonts.sh"
run_script "04-runtimes.sh"
run_script "05-dotfiles.sh"

if [[ "$DEVOPS" == true ]]; then
  run_script "06-devops.sh"
else
  log_skip "DevOps tools (pass --devops to include)"
fi

log_header "Bootstrap Complete!"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. On first zsh launch, Powerlevel10k will run its config wizard"
echo "     (or run: p10k configure)"
echo "  3. In Windows Terminal, set the font to: JetBrainsMono Nerd Font"
echo ""
