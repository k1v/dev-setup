# dev-setup

Automated developer environment setup for **WSL** (and Windows, coming soon).

Sets up: shell (zsh + Oh My Zsh + Powerlevel10k), dotfiles, modern CLI tools, runtime managers (nvm, pyenv), and optionally DevOps tools.

---

## WSL Setup

### Prerequisites

- WSL 2 with Ubuntu 22.04 or 24.04
- [MesloLGL Nerd Font](https://www.nerdfonts.com/font-downloads) installed on Windows and set in Windows Terminal (this is also the font Powerlevel10k recommends by default)

### Usage

#### Fresh distro — one command

The `00-ssh-github.sh` script handles everything on a brand new machine: installs git, generates an SSH key, walks you through adding it to GitHub, verifies the connection, clones this repo, and runs the full bootstrap. Only `curl` is needed (pre-installed in all Ubuntu/Debian distros):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/k1v/dev-setup/master/wsl/scripts/00-ssh-github.sh)
```

To also install DevOps tools, pass the flag through:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/k1v/dev-setup/master/wsl/scripts/00-ssh-github.sh) --devops
```

#### Already have SSH set up?

If your SSH key is already registered with GitHub (e.g. re-running on an existing machine):

```bash
mkdir -p ~/repos
git clone git@github.com:k1v/dev-setup.git ~/repos/dev-setup
bash ~/repos/dev-setup/wsl/bootstrap.sh

# Or with DevOps tools
bash ~/repos/dev-setup/wsl/bootstrap.sh --devops

# Or re-run a single step
bash ~/repos/dev-setup/wsl/bootstrap.sh --step 02
```

After the script finishes:

1. Restart your terminal (`exec zsh` or open a new tab)
2. Powerlevel10k will launch its config wizard on first run — or run `p10k configure` manually
3. In Windows Terminal → Settings → your WSL profile → Appearance → Font: set to **MesloLGL Nerd Font**

---

## What Gets Installed

### Step 01 — System packages

| Package | Purpose |
|---|---|
| `build-essential`, `pkg-config` | Compilers and build tools |
| `git`, `curl`, `wget` | Essential network and SCM tools |
| `gh` | GitHub CLI — create PRs, issues, and manage repos from the terminal |
| `fzf` | Fuzzy finder (`Ctrl+R` history, `Ctrl+T` file search) |
| `ripgrep` (`rg`) | Fast grep replacement |
| `fd-find` (`fd`) | Fast `find` replacement |
| `bat` | `cat` with syntax highlighting |
| `eza` | Modern `ls` with icons and git status |
| `autojump` | Jump to frecently used directories (`j <partial-name>`) |
| `jq`, `htop`, `tree`, `vim` | Everyday utilities |

### Step 02 — Shell

- **zsh** as default shell
- **Oh My Zsh** framework
- Plugins: `git`, `autojump`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Theme: **Powerlevel10k** (instant prompt, git/k8s/node/python segments)

### Step 03 — Fonts (informational)

Prints Windows Terminal font configuration instructions. Fonts are installed on the Windows host.

### Step 04 — Runtime managers

- **nvm** + Node.js LTS
- **pyenv** + latest stable Python

### Step 05 — Dotfiles

Symlinks all files from `wsl/dotfiles/` into `$HOME`. Existing files are backed up to `~/.dotfiles-backup/<timestamp>/`.

| File | Purpose |
|---|---|
| `.zshrc` | Main shell config |
| `.p10k.zsh` | Powerlevel10k theme config |
| `.gitconfig` | Git user, aliases, and sane defaults |
| `.aliases` | Shell aliases for navigation, git, docker, k8s |

### Step 06 — DevOps tools (opt-in via `--devops`)

- `kubectl` (Kubernetes CLI)
- `helm` (Kubernetes package manager)
- `terraform` (HashiCorp IaC)
- `azure-cli` (`az`)

---

## Dotfiles

All dotfiles live in `wsl/dotfiles/`. Edit them directly — they are version-controlled here and symlinked into `$HOME`, so any change is immediately tracked.

Quick edit aliases (available after setup):

```zsh
zshrc     # edit ~/.zshrc
aliases   # edit ~/.aliases
p10krc    # edit ~/.p10k.zsh
reload    # source ~/.zshrc without restarting
```

---

## Idempotency

Every script checks whether its work is already done before doing it. Re-running `bootstrap.sh` is safe and will skip completed steps.

---

## Repository Structure

```
dev-setup/
├── wsl/
│   ├── bootstrap.sh          # Entry point
│   ├── scripts/
│   │   ├── 01-packages.sh
│   │   ├── 02-zsh.sh
│   │   ├── 03-fonts.sh
│   │   ├── 04-runtimes.sh
│   │   ├── 05-dotfiles.sh
│   │   └── 06-devops.sh
│   └── dotfiles/
│       ├── .zshrc
│       ├── .p10k.zsh
│       ├── .gitconfig
│       └── .aliases
└── windows/                  # Coming soon
```

---

## Windows Setup

Coming soon — will cover: winget packages, PowerShell profile, Windows Terminal settings, and font configuration.
