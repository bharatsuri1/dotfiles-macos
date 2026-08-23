readonly HOMEBREW_PREFIX_ARM="/opt/homebrew"
readonly HOMEBREW_PREFIX_INTEL="/usr/local"
readonly HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

homebrew_prefix() {
  if [[ "$(uname -m)" == arm64 ]]; then
    printf '%s\n' "$HOMEBREW_PREFIX_ARM"
  else
    printf '%s\n' "$HOMEBREW_PREFIX_INTEL"
  fi
}

brew_shellenv() {
  local brew_bin="$(homebrew_prefix)/bin/brew"
  [[ -x "$brew_bin" ]] || return 1
  eval "$("$brew_bin" shellenv)"
}

ensure_brew_on_path() {
  command -v brew >/dev/null 2>&1 || brew_shellenv || true
}

install_homebrew() {
  ensure_brew_on_path

  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed at $(command -v brew)"
  else
    log 'installing Homebrew with the official installer'
    if $DRY_RUN; then
      printf '+ /bin/bash -c "$(curl -fsSL %s)"\n' "$HOMEBREW_INSTALLER_URL"
    else
      /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALLER_URL")"
    fi
    ensure_brew_on_path
    command -v brew >/dev/null 2>&1 || die 'Homebrew installation did not provide brew on PATH'
  fi

  local brewfile="$REPO_ROOT/Brewfile"
  [[ -f "$brewfile" ]] || die "managed Brewfile is missing at $brewfile"
  log 'installing managed Homebrew packages from the Brewfile'
  run brew bundle install --verbose --file "$brewfile"
}
