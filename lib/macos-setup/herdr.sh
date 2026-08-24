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

show_herdr_status() {
  printf 'Herdr:\n'
  if [[ -x "$HERDR_BINARY" ]]; then
    printf '  [ok]      %s\n' "$HERDR_BINARY"
  else
    printf '  [missing] %s\n' "$HERDR_BINARY"
  fi

  local target="$HOME/.config/herdr/config.toml"
  local source="$REPO_ROOT/config/herdr/config.toml"
  local resolved=""
  if [[ -L "$target" ]]; then
    resolved="$(readlink -f -- "$target" 2>/dev/null || true)"
  fi
  if [[ "$resolved" == "$(readlink -f -- "$source" 2>/dev/null || true)" ]]; then
    printf '  [linked]  %s\n' "$target"
  elif [[ -L "$target" && -z "$resolved" ]]; then
    printf '  [broken]  %s\n' "$target"
  elif [[ -L "$target" ]]; then
    printf '  [wrong]   %s -> %s\n' "$target" "$resolved"
  elif [[ -e "$target" ]]; then
    printf '  [local]   %s\n' "$target"
  else
    printf '  [missing] %s\n' "$target"
  fi
}
