#!/usr/bin/env bash
set -xeuo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/lima-alvaro/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

DOTFILES_ZSHRC_PATH="${DOTFILES_ZSHRC_PATH:-zsh/.zshrc}"
DOTFILES_NVIM_DIR="${DOTFILES_NVIM_DIR:-nvim}"
DOTFILES_TMUX_PATH="${DOTFILES_TMUX_PATH:-tmux/.tmux.conf}"

NVIM_VERSION="${NVIM_VERSION:-0.11.3}"
NVIM_URL="${NVIM_URL:-https://github.com/neovim/neovim-releases/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz}"

NODE_MAJOR="${NODE_MAJOR:-24}"

SPACESHIP_REPO="${SPACESHIP_REPO:-https://github.com/spaceship-prompt/spaceship-prompt.git}"
SPACESHIP_DIR="${SPACESHIP_DIR:-$HOME/.oh-my-zsh/custom/themes/spaceship-prompt}"

ZSH_PLUGINS=(
    "junegunn/fzf"
    "Aloxaf/fzf-tab"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
)

need_root() {
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "This script is meant to run as root in a Docker container."
        exit 1
    fi
}

install_apt() {
    need_root
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y --no-install-recommends \
        zsh \
        git \
        curl \
        ca-certificates \
        bsdextrautils \
        fd-find \
        fzf \
        openssh-client \
        less \
        procps \
        ripgrep \
        tmux \
        wl-clipboard \
        xz-utils \
        tar \
        gzip \
        python3 \
        python3-pip \
        python3-venv \
        build-essential

    rm -rf /var/lib/apt/lists/*
}

install_node() {
    need_root

    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
    apt-get install -y --no-install-recommends nodejs

    node -v
    npm -v

    npm install -g tree-sitter-cli@0.22.6 --build-from-source
    npm install -g @openai/codex
}

install_nvim() {
    need_root

    echo "Downloading Neovim ${NVIM_VERSION}..."
    curl -fL -o /tmp/nvim.tar.gz "$NVIM_URL"

    rm -rf /opt/nvim "/usr/local/bin/nvim"
    mkdir -p /opt

    tar -xzf /tmp/nvim.tar.gz -C /opt

    if [ ! -d /opt/nvim-linux-x86_64 ]; then
        echo "Expected /opt/nvim-linux-x86_64 after extraction, but it was not found."
        ls -la /opt
        exit 1
    fi

    mv /opt/nvim-linux-x86_64 /opt/nvim
    ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

    rm -f /tmp/nvim.tar.gz

    nvim --version | head -n 2
}

install_black() {
    need_root

    python3 -m venv /opt/venvs/black
    /opt/venvs/black/bin/pip install --no-cache-dir --upgrade pip
    /opt/venvs/black/bin/pip install --no-cache-dir black
    ln -sf /opt/venvs/black/bin/black /usr/local/bin/black

    black --version
}

install_oh_my_zsh() {
    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

clone_plugins() {
    local zsh_custom
    zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    mkdir -p "$zsh_custom/plugins"

    for repo in "${ZSH_PLUGINS[@]}"; do
        local name
        local target

        name="${repo##*/}"
        target="$zsh_custom/plugins/$name"

        if [ ! -d "$target/.git" ]; then
            git clone --depth=1 "https://github.com/$repo.git" "$target"
        else
            git -C "$target" fetch --depth=1 origin
            git -C "$target" reset --hard origin/HEAD
        fi
    done
}

clone_spaceship_theme() {
    local zsh_custom
    local spaceship_link

    zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    spaceship_link="$zsh_custom/themes/spaceship.zsh-theme"

    mkdir -p "$zsh_custom/themes"

    if [ ! -d "$SPACESHIP_DIR/.git" ]; then
        git clone --depth=1 "$SPACESHIP_REPO" "$SPACESHIP_DIR"
    else
        git -C "$SPACESHIP_DIR" fetch --depth=1 origin
        git -C "$SPACESHIP_DIR" reset --hard origin/HEAD
    fi

    ln -sf "$SPACESHIP_DIR/spaceship.zsh-theme" "$spaceship_link"
}

clone_dotfiles() {
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        git -C "$DOTFILES_DIR" fetch --depth=1 origin
        git -C "$DOTFILES_DIR" reset --hard origin/HEAD
    fi
}

install_configs() {
    mkdir -p "$HOME/.config"

    ln -sfnT "$DOTFILES_DIR/$DOTFILES_ZSHRC_PATH" "$HOME/.zshrc"
    ln -sfnT "$DOTFILES_DIR/$DOTFILES_NVIM_DIR" "$HOME/.config/nvim"
    ln -sfnT "$DOTFILES_DIR/$DOTFILES_TMUX_PATH" "$HOME/.tmux.conf"

    "$DOTFILES_DIR/ipython/install-ipython.sh"
}

install_tmux_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [ ! -d "$tpm_dir/.git" ]; then
        git clone --depth=1 https://github.com/tmux-plugins/tpm.git "$tpm_dir"
    fi

    "$tpm_dir/bin/install_plugins"
}

main() {
    install_apt
    install_node
    install_nvim
    install_black
    install_oh_my_zsh
    clone_plugins
    clone_spaceship_theme
    clone_dotfiles
    install_configs
    install_tmux_plugins

    echo
    echo "Setup finished."
    echo "node:  $(node -v)"
    echo "npm:   $(npm -v)"
    echo "nvim:  $(nvim --version | head -n 1)"
    echo "black: $(black --version | head -n 1)"
    echo "zsh:   $(zsh --version)"
}

main "$@"
