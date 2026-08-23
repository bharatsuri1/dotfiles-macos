readonly YAZI_CONFIG_SOURCE="$REPO_ROOT/config/yazi"
readonly YAZI_CONFIG_TARGET="$HOME/.config/yazi"

yazi_installed() {
  command -v yazi >/dev/null 2>&1
}

install_yazi() {
  if ! yazi_installed && ! $DRY_RUN; then
    die 'Yazi is missing; run the homebrew phase first'
  fi
  if ! yazi_installed && $DRY_RUN; then
    log 'Yazi is not installed; would still link managed configuration'
  fi

  link_config "$YAZI_CONFIG_SOURCE" "$YAZI_CONFIG_TARGET"
}
