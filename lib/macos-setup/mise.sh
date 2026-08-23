readonly MISE_NODE_VERSION="latest"

mise_installed() {
  command -v mise >/dev/null 2>&1
}

install_mise() {
  if ! mise_installed && ! $DRY_RUN; then
    die 'mise is missing; run the homebrew phase first'
  fi
  if ! mise_installed && $DRY_RUN; then
    log "mise is not installed; would install node@$MISE_NODE_VERSION"
    printf '+ mise use --global node@%s\n' "$MISE_NODE_VERSION"
    return
  fi

  if mise ls --installed --global 2>/dev/null | grep -Eq '^node\b'; then
    log 'mise-managed Node already installed globally'
    return
  fi
  log "installing Node.js $MISE_NODE_VERSION via mise"
  run mise use --global "node@$MISE_NODE_VERSION"
}
