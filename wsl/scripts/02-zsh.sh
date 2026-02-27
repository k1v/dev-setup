#!/usr/bin/env bash
# =============================================================================
# 02-zsh.sh — zsh, Oh My Zsh, plugins, Powerlevel10k theme
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RESET='\033[0m'
info() { echo -e "${CYAN}[zsh] $1${RESET}"; }
ok()   { echo -e "${GREEN}[zsh] $1${RESET}"; }

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ---------------------------------------------------------------------------
# 1. Set zsh as default shell
# ---------------------------------------------------------------------------
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  info "Setting zsh as default shell..."
  sudo chsh -s "$(command -v zsh)" "$USER"
  ok "Default shell changed to zsh (takes effect on next login)"
else
  ok "zsh is already the default shell — skipping"
fi

# ---------------------------------------------------------------------------
# 2. Oh My Zsh
# ---------------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  # RUNZSH=no prevents it from launching zsh mid-script
  # KEEP_ZSHRC=yes prevents it from overwriting our dotfile symlink
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed — skipping"
fi

# ---------------------------------------------------------------------------
# 3. Plugins: zsh-autosuggestions
# ---------------------------------------------------------------------------
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ ! -d "$PLUGIN_DIR" ]]; then
  info "Installing zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR"
  ok "zsh-autosuggestions installed"
else
  ok "zsh-autosuggestions already installed — skipping"
fi

# ---------------------------------------------------------------------------
# 4. Plugins: zsh-syntax-highlighting
# ---------------------------------------------------------------------------
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ ! -d "$PLUGIN_DIR" ]]; then
  info "Installing zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR"
  ok "zsh-syntax-highlighting installed"
else
  ok "zsh-syntax-highlighting already installed — skipping"
fi

# ---------------------------------------------------------------------------
# 5. Theme: Powerlevel10k
# ---------------------------------------------------------------------------
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k "$P10K_DIR"
  ok "Powerlevel10k installed"
else
  ok "Powerlevel10k already installed — skipping"
fi

ok "zsh setup complete."
echo ""
echo "  Plugins installed: git, autojump, zsh-autosuggestions, zsh-syntax-highlighting"
echo "  Theme: powerlevel10k/powerlevel10k"
echo "  Run 'p10k configure' after first launch to customise the prompt."
