readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-macos"
readonly BACKUP_ROOT="$STATE_DIR/backups"

DRY_RUN=false
ASSUME_YES=false
if [[ "${DOTFILES_MACOS_ASSUME_YES:-}" == 1 ]]; then
  ASSUME_YES=true
fi
BACKUP_DIR=""

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  if $DRY_RUN; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

confirm() {
  local prompt="$1"
  [[ -n "$prompt" ]] || die 'confirm requires a prompt'
  if $ASSUME_YES; then
    log "$prompt [assumed yes]"
    return 0
  fi
  local answer
  if [[ -r /dev/tty ]]; then
    read -r -p "$prompt [y/N] " answer </dev/tty
  else
    die "interactive confirmation requires a terminal: $prompt"
  fi
  [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]
}

require_macos() {
  [[ "$(uname -s)" == Darwin ]] || die 'this CLI currently supports macOS only'
}
