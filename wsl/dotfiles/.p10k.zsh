# ==============================================================================
# .p10k.zsh — Powerlevel10k prompt configuration
# Managed by: https://github.com/k1v/dev-setup
#
# This is a pre-tuned "lean" style config designed for WSL + Windows Terminal
# with JetBrainsMono Nerd Font.
#
# To re-run the interactive wizard: p10k configure
# ==============================================================================

# Temporarily change options
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # ────────────────────────────────────────────────────────────────────────────
  # Prompt layout
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon               # OS icon (Tux on Linux)
    dir                   # current directory
    vcs                   # git status
    newline               # new line
    prompt_char           # ❯ prompt character
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                # exit code
    command_execution_time # duration of last command
    background_jobs       # background job count
    node_version          # node version if in a node project
    python_version        # python version if in a python project (via pyenv)
    kubecontext           # kubernetes context if kubectl configured
    virtualenv            # python venv
    nvm                   # node version manager
    context               # user@host if SSH or root
    newline               # newline before timestamp
    time                  # current time
  )

  # ────────────────────────────────────────────────────────────────────────────
  # Basic colours and style
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  typeset -g POWERLEVEL9K_BACKGROUND=                 # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'

  # Prompt spacing
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # ────────────────────────────────────────────────────────────────────────────
  # OS icon
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=212

  # ────────────────────────────────────────────────────────────────────────────
  # Prompt character
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_RIGHT_WHITESPACE=' '

  # ────────────────────────────────────────────────────────────────────────────
  # Directory
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

  # Show 3 path segments from the right before truncating
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3

  # Don't shorten the home directory
  local anchors=(
    $HOME
    /
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchors})"

  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # ────────────────────────────────────────────────────────────────────────────
  # Git (vcs)
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

  # Clean (green), modified (yellow), untracked (blue)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=39
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=196

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=false
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=5

  # ────────────────────────────────────────────────────────────────────────────
  # Exit status
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

  # ────────────────────────────────────────────────────────────────────────────
  # Command execution time
  # ────────────────────────────────────────────────────────────────────────────
  # Show only when command takes longer than 3s
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101

  # ────────────────────────────────────────────────────────────────────────────
  # Background jobs
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=70

  # ────────────────────────────────────────────────────────────────────────────
  # Time
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # ────────────────────────────────────────────────────────────────────────────
  # Context (user@host) — show only if SSH or root
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%F{red}%n@%m%f%b'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # ────────────────────────────────────────────────────────────────────────────
  # Node version (shown only in Node projects)
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_NODE_ICON='\uF898'

  # ────────────────────────────────────────────────────────────────────────────
  # Python version (shown only in Python projects)
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_PYTHON_VERSION_PROJECT_ONLY=true

  # ────────────────────────────────────────────────────────────────────────────
  # Kubernetes context (shown only when kubectl is configured)
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|k9s|terraform'
  typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=134

  # ────────────────────────────────────────────────────────────────────────────
  # Instant prompt
  # ────────────────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # ────────────────────────────────────────────────────────────────────────────
  # Hot reload
  # ────────────────────────────────────────────────────────────────────────────
  (( ! $+functions[p10k] )) || p10k reload
} always {
  'builtin' 'unsetopt' 'aliases' 'sh_glob' 'no_brace_expand'
  local opt
  for opt in "${p10k_config_opts[@]}"; do
    'builtin' 'setopt' "$opt"
  done
}
