readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-macos"
# Used by link_config in shell.sh.
# shellcheck disable=SC2034
readonly BACKUP_ROOT="$STATE_DIR/backups"

# Read by output.sh and the phase scripts.
# shellcheck disable=SC2034
DRY_RUN=false
ASSUME_YES=false
if [[ "${DOTFILES_MACOS_ASSUME_YES:-}" == 1 ]]; then
  ASSUME_YES=true
fi
# Used by link_config in shell.sh.
# shellcheck disable=SC2034
BACKUP_DIR=""

confirm() {
  local prompt="$1"
  [[ -n "$prompt" ]] || die 'confirm requires a prompt'
  if $ASSUME_YES; then
    report local "$prompt [assumed yes]"
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
