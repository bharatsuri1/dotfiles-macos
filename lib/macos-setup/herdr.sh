readonly HERDR_INSTALLER_URL="https://herdr.dev/install.sh"
readonly HERDR_BINARY="$HOME/.local/bin/herdr"

install_herdr() {
  link_config "$REPO_ROOT/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

  if [[ -x "$HERDR_BINARY" ]]; then
    log "herdr already installed at $HERDR_BINARY"
    return
  fi

  if $DRY_RUN; then
    log 'would download, inspect, and run the official herdr installer'
    printf '+ curl -fsSLo <temporary-installer> %q\n' "$HERDR_INSTALLER_URL"
    printf '+ sh <temporary-installer>\n'
    return
  fi

  local installer checksum
  installer="$(mktemp)"
  curl -fsSLo "$installer" "$HERDR_INSTALLER_URL"
  checksum="$(shasum -a 256 "$installer" | awk '{print $1}')"
  log "herdr installer downloaded to $installer (SHA-256: $checksum)"

  if ! confirm 'Run the official herdr installer now?'; then
    die "herdr installation declined; inspect $installer and rerun this phase"
  fi

  sh "$installer"
  rm -f -- "$installer"
  [[ -x "$HERDR_BINARY" ]] || die 'herdr installer did not produce ~/.local/bin/herdr'
}
