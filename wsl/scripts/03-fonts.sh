#!/usr/bin/env bash
# =============================================================================
# 03-fonts.sh — Nerd Fonts notice
# =============================================================================
# Fonts are installed on the Windows host, not inside WSL.
# This script just verifies the expected font is visible and prints guidance.
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'
info() { echo -e "${CYAN}[fonts] $1${RESET}"; }
ok()   { echo -e "${GREEN}[fonts] $1${RESET}"; }
warn() { echo -e "${YELLOW}[fonts] $1${RESET}"; }

info "Checking font availability..."

# Check if fc-list is available (fontconfig)
if command -v fc-list &>/dev/null; then
  if fc-list | grep -qi "MesloLGL"; then
    ok "MesloLGL Nerd Font detected via fontconfig."
  elif fc-list | grep -qi "Meslo"; then
    ok "Meslo font detected via fontconfig."
  else
    warn "MesloLGL Nerd Font not found via fc-list."
    warn "This is expected if fonts are installed only on the Windows host."
  fi
else
  info "fontconfig (fc-list) not available — skipping font detection."
fi

ok "Font step complete."
echo ""
echo -e "  ${BOLD}Windows Terminal font configuration:${RESET}"
echo "  ─────────────────────────────────────────────────────────────"
echo "  Recommended font: MesloLGL Nerd Font (also the default used"
echo "  by the Powerlevel10k configuration wizard)"
echo ""
echo "  1. Open Windows Terminal → Settings (Ctrl+,)"
echo "  2. Select your WSL profile on the left"
echo "  3. Go to: Appearance → Font face"
echo "  4. Set to:  MesloLGL Nerd Font"
echo "     (or:     MesloLGL NF / MesloLGLDZ Nerd Font)"
echo "  5. Recommended size: 11-12pt"
echo "  ─────────────────────────────────────────────────────────────"
echo "  If the font isn't installed yet, download from:"
echo "  https://www.nerdfonts.com/font-downloads  →  Meslo"
echo ""
