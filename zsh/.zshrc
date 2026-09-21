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

export EDITOR=nvim
export VISUAL=nvim

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
# Load Oh My Zsh
# ----------------------------------------
source "$ZSH/oh-my-zsh.sh"

zsh_dir="${${(%):-%x}:A:h}"
for file in "$zsh_dir/"*.sh(N); do
    source "$file"
done
