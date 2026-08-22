#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="${DOTFILES_MACOS_REPOSITORY_URL:-https://github.com/bharatsuri1/dotfiles-macos.git}"
readonly INSTALL_ROOT="${DOTFILES_MACOS_INSTALL_ROOT:-$HOME/.local/share/dotfiles-macos}"

readonly GIT_NAME="${DOTFILES_GIT_NAME:-Bharat Suri}"
readonly GIT_EMAIL="${DOTFILES_GIT_EMAIL:-bharatsuri.us@gmail.com}"

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

[[ "$(uname -s)" == Darwin ]] || die 'this bootstrap currently supports macOS only'

if ! command -v git >/dev/null 2>&1 || ! xcode-select --print-path >/dev/null 2>&1; then
  log 'requesting the Xcode Command Line Tools installation'
  xcode-select --install >/dev/null 2>&1 || true
  die 're-run this bootstrap after the Command Line Tools installation completes'
fi

if [[ -d "$INSTALL_ROOT/.git" ]]; then
  log "updating existing checkout at $INSTALL_ROOT"
  current_branch="$(git -C "$INSTALL_ROOT" symbolic-ref --quiet --short HEAD)" ||
    die "$INSTALL_ROOT has a detached HEAD; check out main before running the installed command"
  [[ "$current_branch" == main ]] ||
    die "$INSTALL_ROOT is on branch $current_branch; check out main or run ./bin/macos-setup to use it unchanged"
  git -C "$INSTALL_ROOT" pull --ff-only origin main
elif [[ -e "$INSTALL_ROOT" ]]; then
  die "$INSTALL_ROOT exists but is not a Git checkout; move it aside or set DOTFILES_MACOS_INSTALL_ROOT"
else
  log "cloning dotfiles-macos into $INSTALL_ROOT"
  mkdir -p "$(dirname -- "$INSTALL_ROOT")"
  git clone "$REPOSITORY_URL" "$INSTALL_ROOT"
fi

log 'configuring Git defaults'

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.autoSetupRemote true

log 'starting the guided macOS setup'
if (($#)); then
  exec "$INSTALL_ROOT/bin/macos-setup" "$@"
else
  exec "$INSTALL_ROOT/bin/macos-setup" apply
fi
