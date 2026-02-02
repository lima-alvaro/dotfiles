# ----------------------------------------
# ----------------------------------------
# PATH
# ----------------------------------------

export PATH="$HOME/.local/opt/node-24/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Oh My Zsh
# ----------------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

plugins=(
    git
    fzf
    fzf-tab
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Extra completions path.
# Put this before Oh My Zsh loads compinit.
fpath=(
    "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src"
    $fpath
)

# ----------------------------------------
# Spaceship Prompt
# ----------------------------------------

SPACESHIP_PROMPT_ORDER=(
    user
    dir
    venv
    git_branch
    git_status
    line_sep
    char
)

SPACESHIP_VENV_SHOW=true
SPACESHIP_VENV_GENERIC_NAMES=(
    reallybro
)
SPACESHIP_VENV_PREFIX="("
SPACESHIP_VENV_SUFFIX=") "

SPACESHIP_USER_SHOW=always
SPACESHIP_HOST_SHOW=always

SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false

SPACESHIP_GIT_SHOW=true
SPACESHIP_GIT_BRANCH_SHOW=true
SPACESHIP_GIT_STATUS_SHOW=true

# Disable async if you want Git info immediately after cd.
# Slower, but avoids "one prompt late" behavior.
SPACESHIP_GIT_ASYNC=false
SPACESHIP_GIT_BRANCH_ASYNC=false


# ----------------------------------------
# History
# ----------------------------------------

HISTSIZE=5000
SAVEHIST=5000
HISTFILE="$HOME/.zsh_history"

setopt append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_find_no_dups

# ----------------------------------------
# Aliases
# ----------------------------------------

alias vim="nvim"
alias vi="nvim"
alias oldvim="\\vim"
alias icat="kitty +kitten icat"

alias ls="ls --color"

# ----------------------------------------
# Functions
# ----------------------------------------

pod_get() {
    emulate -L zsh
    setopt errexit nounset pipefail

    local POD_PREFIX="${1:-modhydro-dataobs}"
    local REMOTE_PATH="${2:-}"
    local LOCAL_PATH="${3:-.}"
    local NAMESPACE="${4:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}"
    NAMESPACE="${NAMESPACE:-default}"

    if [[ -z "$REMOTE_PATH" ]]; then
        echo "Usage: pod_get [pod-prefix] <remote-path> [local-path] [namespace]"
        return 1
    fi

    local POD_NAME
    POD_NAME="$(
        kubectl get pods -n "$NAMESPACE" \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' |
            grep -m1 "^${POD_PREFIX}"
    )"

    if [[ -z "$POD_NAME" ]]; then
        echo "No pod found matching: $POD_PREFIX (ns: $NAMESPACE)" >&2
        return 1
    fi

    echo "Using namespace: $NAMESPACE"
    echo "Using pod: $POD_NAME"
    echo "Copying: $REMOTE_PATH -> $LOCAL_PATH"

    kubectl cp -n "$NAMESPACE" "${POD_NAME}:${REMOTE_PATH}" "$LOCAL_PATH"
}

csvview() {
    sed -e 's/,,/, ,/g' "$1" | column -s, -t | less -#5 -N -S
}

# ----------------------------------------
# Load Oh My Zsh
# ----------------------------------------

source "$ZSH/oh-my-zsh.sh"
