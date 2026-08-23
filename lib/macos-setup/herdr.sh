readonly HERDR_INSTALLER_URL="https://herdr.dev/install.sh"

herdr_installed() {
  command -v herdr >/dev/null 2>&1
}

install_herdr() {
  if herdr_installed; then
    log "herdr already installed at $(command -v herdr)"
    return
  fi

  if $DRY_RUN; then
    printf '+ curl -fsSL %s | sh\n' "$HERDR_INSTALLER_URL"
    return
  fi

  log 'installing herdr via the official installer'
  curl -fsSL "$HERDR_INSTALLER_URL" | sh
  command -v herdr >/dev/null 2>&1 || die 'herdr installation did not put herdr on PATH'
}
