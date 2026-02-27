#!/usr/bin/env bash
# =============================================================================
# 04-runtimes.sh — nvm/Node.js + pyenv/Python
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RESET='\033[0m'
info() { echo -e "${CYAN}[runtimes] $1${RESET}"; }
ok()   { echo -e "${GREEN}[runtimes] $1${RESET}"; }

# ---------------------------------------------------------------------------
# nvm — Node Version Manager
# ---------------------------------------------------------------------------
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ ! -d "$NVM_DIR" ]]; then
  info "Installing nvm..."
  # Always installs the latest nvm release
  NVM_LATEST=$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest \
    | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_LATEST}/install.sh" | bash
  ok "nvm v${NVM_LATEST} installed"
else
  ok "nvm already installed — skipping"
fi

# Load nvm into this script's shell context so we can use it immediately
export NVM_DIR
# shellcheck source=/dev/null
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Install Node.js LTS if not present
if ! nvm ls --no-colors 2>/dev/null | grep -q "lts/"; then
  info "Installing Node.js LTS via nvm..."
  nvm install --lts
  nvm alias default 'lts/*'
  ok "Node.js LTS installed: $(node --version)"
else
  ok "Node.js LTS already installed — skipping"
fi

# ---------------------------------------------------------------------------
# pyenv — Python Version Manager
# ---------------------------------------------------------------------------
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if [[ ! -d "$PYENV_ROOT" ]]; then
  info "Installing pyenv..."
  # pyenv-installer handles everything
  curl -fsSL https://pyenv.run | bash
  ok "pyenv installed"
else
  ok "pyenv already installed — skipping"
fi

# Load pyenv into this script's context
export PYENV_ROOT
export PATH="$PYENV_ROOT/bin:$PATH"
# shellcheck source=/dev/null
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
fi

# Install latest stable Python 3.13.x if none installed yet
# We pin to 3.13.x (not the absolute latest) to avoid bleeding-edge
# releases that may have build issues (e.g. 3.14.x pip bootstrap bug)
if ! pyenv versions --bare 2>/dev/null | grep -qE "^[0-9]"; then
  info "Installing latest stable Python 3.13.x via pyenv..."
  LATEST_PYTHON=$(pyenv install --list \
    | grep -E '^\s+3\.13\.[0-9]+$' \
    | tail -1 \
    | tr -d ' ')
  if [[ -z "$LATEST_PYTHON" ]]; then
    echo -e "\033[1;33m[runtimes] Could not find Python 3.13.x in pyenv list — skipping Python install\033[0m"
    echo "           Run manually later: pyenv install 3.13.x && pyenv global 3.13.x"
  else
    if pyenv install "$LATEST_PYTHON"; then
      pyenv global "$LATEST_PYTHON"
      ok "Python $LATEST_PYTHON installed and set as global"
    else
      echo -e "\033[1;33m[runtimes] Python $LATEST_PYTHON build failed — skipping\033[0m"
      echo "           Run manually later: pyenv install $LATEST_PYTHON && pyenv global $LATEST_PYTHON"
    fi
  fi
else
  CURRENT=$(pyenv version-name 2>/dev/null || echo "unknown")
  ok "Python already installed ($CURRENT) — skipping"
fi

ok "Runtime setup complete."
echo ""
echo "  nvm  : $(nvm --version 2>/dev/null || echo 'load nvm in a new shell')"
echo "  node : $(node --version 2>/dev/null || echo 'load nvm in a new shell')"
echo "  pyenv: $(pyenv --version 2>/dev/null || echo 'load pyenv in a new shell')"
echo "  python: $(python --version 2>/dev/null || echo 'load pyenv in a new shell')"
