readonly OPENCODE_INSTALLER_URL="https://opencode.ai/v2/install"
readonly OPENCODE_BINARY="$HOME/.opencode/bin/opencode"

download_and_install_opencode() (
  local installer checksum
  installer="$(mktemp)"
  trap 'run rm -f -- "$installer"' EXIT
  run curl -fsSLo "$installer" "$OPENCODE_INSTALLER_URL"
  checksum="$(shasum -a 256 "$installer" | awk '{print $1}')"
  log "OpenCode installer downloaded to $installer (SHA-256: $checksum)"
  run bash "$installer" --no-modify-path
)

install_opencode() {
  section OpenCode
  if [[ -x "$OPENCODE_BINARY" ]]; then
    log "OpenCode already installed at $OPENCODE_BINARY"
  elif $DRY_RUN; then
    log 'would download and run the official OpenCode v2 installer'
    printf '+ curl -fsSLo <temporary-installer> %q\n' "$OPENCODE_INSTALLER_URL"
    printf '+ bash <temporary-installer> --no-modify-path\n'
  else
    download_and_install_opencode
  fi

  if ! $DRY_RUN; then
    [[ -x "$OPENCODE_BINARY" ]] || die 'OpenCode installer did not produce ~/.opencode/bin/opencode'
    "$OPENCODE_BINARY" --version || die 'OpenCode binary failed; keeping the legacy npm package'
  fi

  # Remove the old package only after the replacement is available and runnable.
  if command -v mise >/dev/null 2>&1 && npm_tool_installed opencode-ai; then
    log 'removing legacy npm package opencode-ai'
    run mise exec node@latest -- npm uninstall --global opencode-ai
  fi
}

show_opencode_status() {
  section OpenCode
  if [[ -x "$OPENCODE_BINARY" ]]; then
    report ok "$OPENCODE_BINARY"
  else
    report missing "$OPENCODE_BINARY; run macos-setup opencode"
  fi
}
