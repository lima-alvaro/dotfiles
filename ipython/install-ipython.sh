#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IPYTHON_VENV="${IPYTHON_VENV:-$HOME/.local/opt/ipython}"

mkdir -p "$HOME/.ipython/profile_default/startup/"
mkdir -p "$HOME/.local/bin"

python3 -m venv "$IPYTHON_VENV"
"$IPYTHON_VENV/bin/pip" install --disable-pip-version-check \
    -r "$DOTFILES_DIR/ipython/requirements-ipython.txt"

ln -sfn "$IPYTHON_VENV/bin/ipython" "$HOME/.local/bin/ipython"

ln -sf \
    "$DOTFILES_DIR/ipython/ipython_config.py" \
    "$HOME/.ipython/profile_default/ipython_config.py"

ln -sf \
    "$DOTFILES_DIR/ipython/startup/00-startup.py" \
    "$HOME/.ipython/profile_default/startup/00-startup.py"
