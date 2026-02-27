#!/usr/bin/env bash
# =============================================================================
# 06-devops.sh — DevOps tools: kubectl, helm, terraform, azure-cli
# =============================================================================
# Run via: ./bootstrap.sh --devops
# Or directly: bash wsl/scripts/06-devops.sh
# =============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RESET='\033[0m'
info() { echo -e "${CYAN}[devops] $1${RESET}"; }
ok()   { echo -e "${GREEN}[devops] $1${RESET}"; }

# ---------------------------------------------------------------------------
# kubectl — Kubernetes CLI
# ---------------------------------------------------------------------------
if ! command -v kubectl &>/dev/null; then
  info "Installing kubectl..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq kubectl
  ok "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
  ok "kubectl already installed — skipping ($(kubectl version --client --short 2>/dev/null || true))"
fi

# ---------------------------------------------------------------------------
# helm — Kubernetes package manager
# ---------------------------------------------------------------------------
if ! command -v helm &>/dev/null; then
  info "Installing helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  ok "helm installed: $(helm version --short)"
else
  ok "helm already installed — skipping ($(helm version --short))"
fi

# ---------------------------------------------------------------------------
# terraform — Infrastructure as Code
# ---------------------------------------------------------------------------
if ! command -v terraform &>/dev/null; then
  info "Installing terraform..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq terraform
  ok "terraform installed: $(terraform version | head -1)"
else
  ok "terraform already installed — skipping ($(terraform version | head -1))"
fi

# ---------------------------------------------------------------------------
# Azure CLI
# ---------------------------------------------------------------------------
if ! command -v az &>/dev/null; then
  info "Installing Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  ok "Azure CLI installed: $(az version --query '\"azure-cli\"' -o tsv)"
else
  ok "Azure CLI already installed — skipping ($(az version --query '\"azure-cli\"' -o tsv))"
fi

ok "DevOps tools setup complete."
echo ""
echo "  kubectl  : $(kubectl version --client --short 2>/dev/null || echo 'installed')"
echo "  helm     : $(helm version --short 2>/dev/null || echo 'installed')"
echo "  terraform: $(terraform version | head -1 | sed 's/Terraform //' 2>/dev/null || echo 'installed')"
echo "  az cli   : $(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo 'installed')"
