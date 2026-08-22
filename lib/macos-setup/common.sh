readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-macos"
readonly BACKUP_ROOT="$STATE_DIR/backups"

DRY_RUN=false
ASSUME_YES=false
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
  $ASSUME_YES && return 0
  local answer
  if [[ -r /dev/tty ]]; then
    read -r -p "$prompt [y/N] " answer </dev/tty
  else
    die 'interactive confirmation requires a terminal; rerun with --yes for non-interactive use'
  fi
  [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]
}

require_macos() {
  [[ "$(uname -s)" == Darwin ]] || die 'this CLI currently supports macOS only'
}
