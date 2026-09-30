#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="${DOTFILES_MACOS_REPOSITORY_URL:-https://github.com/bharatsuri1/dotfiles-macos.git}"
readonly INSTALL_ROOT="${DOTFILES_MACOS_INSTALL_ROOT:-$HOME/.local/share/dotfiles-macos}"

readonly GIT_NAME="${DOTFILES_GIT_NAME:-Bharat Suri}"
readonly GIT_EMAIL="${DOTFILES_GIT_EMAIL:-bharatsuri.us@gmail.com}"

DRY_RUN=false
setup_args=()
while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true; setup_args+=("$1"); shift ;;
    --) shift; setup_args+=("$@"); break ;;
    *) setup_args+=("$1"); shift ;;
  esac
done

_bootstrap_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$_bootstrap_dir/lib/macos-setup/output.sh"
unset _bootstrap_dir

[[ "$(uname -s)" == Darwin ]] || die 'this bootstrap currently supports macOS only'

if ! command -v git >/dev/null 2>&1 || ! xcode-select --print-path >/dev/null 2>&1; then
  log 'requesting the Xcode Command Line Tools installation'
  if $DRY_RUN; then
    printf '+ xcode-select --install\n'
    log 're-run this bootstrap after the Command Line Tools installation completes'
    exit 0
  fi
  xcode-select --install >/dev/null 2>&1 || true
  die 're-run this bootstrap after the Command Line Tools installation completes'
fi

section Checkout
if [[ -d "$INSTALL_ROOT/.git" ]]; then
  log "updating existing checkout at $INSTALL_ROOT"
  current_branch="$(git -C "$INSTALL_ROOT" symbolic-ref --quiet --short HEAD)" ||
    die "$INSTALL_ROOT has a detached HEAD; check out main before running the installed command"
  [[ "$current_branch" == main ]] ||
    die "$INSTALL_ROOT is on branch $current_branch; check out main or run ./bin/macos-setup to use it unchanged"
  run git -C "$INSTALL_ROOT" pull --ff-only origin main
elif [[ -e "$INSTALL_ROOT" ]]; then
  die "$INSTALL_ROOT exists but is not a Git checkout; move it aside or set DOTFILES_MACOS_INSTALL_ROOT"
else
  log "cloning dotfiles-macos into $INSTALL_ROOT"
  run mkdir -p "$(dirname -- "$INSTALL_ROOT")"
  run git clone "$REPOSITORY_URL" "$INSTALL_ROOT"
fi

section "Git defaults"
log 'configuring Git defaults'

run git config --global user.name "$GIT_NAME"
run git config --global user.email "$GIT_EMAIL"
run git config --global init.defaultBranch main
run git config --global pull.rebase false
run git config --global push.autoSetupRemote true

if $DRY_RUN && [[ ! -d "$INSTALL_ROOT/.git" ]]; then
  log 'would start macos-setup after the checkout exists'
  if ((${#setup_args[@]})); then
    printf '+ '
    printf '%q ' "$INSTALL_ROOT/bin/macos-setup" "${setup_args[@]}"
    printf '\n'
  else
    printf '+ %q apply\n' "$INSTALL_ROOT/bin/macos-setup"
  fi
  exit 0
fi

section Setup
log 'starting the guided macOS setup'
if ((${#setup_args[@]})); then
  exec "$INSTALL_ROOT/bin/macos-setup" "${setup_args[@]}"
else
  exec "$INSTALL_ROOT/bin/macos-setup" apply
fi
