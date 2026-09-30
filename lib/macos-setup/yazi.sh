readonly YAZI_CONFIG_SOURCE="$REPO_ROOT/config/yazi"
readonly YAZI_CONFIG_TARGET="$HOME/.config/yazi"

yazi_installed() {
  command -v yazi >/dev/null 2>&1
}

install_yazi() {
  section Yazi
  if ! yazi_installed && ! $DRY_RUN; then
    die 'Yazi is missing; run the homebrew phase first'
  fi
  if ! yazi_installed && $DRY_RUN; then
    log 'Yazi is not installed; would still link managed configuration'
  fi

  link_config "$YAZI_CONFIG_SOURCE" "$YAZI_CONFIG_TARGET"
}

show_yazi_status() {
  section Yazi
  if yazi_installed; then
    report ok "$(command -v yazi)"
  else
    report missing "yazi"
  fi

  local resolved=""
  if [[ -L "$YAZI_CONFIG_TARGET" ]]; then
    resolved="$(readlink -f -- "$YAZI_CONFIG_TARGET" 2>/dev/null || true)"
  fi
  if [[ "$resolved" == "$(readlink -f -- "$YAZI_CONFIG_SOURCE" 2>/dev/null || true)" ]]; then
    report linked "$YAZI_CONFIG_TARGET"
  elif [[ -L "$YAZI_CONFIG_TARGET" && -z "$resolved" ]]; then
    report broken "$YAZI_CONFIG_TARGET"
  elif [[ -L "$YAZI_CONFIG_TARGET" ]]; then
    report wrong "$YAZI_CONFIG_TARGET -> $resolved"
  elif [[ -e "$YAZI_CONFIG_TARGET" ]]; then
    report local "$YAZI_CONFIG_TARGET"
  else
    report missing "$YAZI_CONFIG_TARGET"
  fi

  # The `y` wrapper is shell-config owned; report whether the managed alias file defines it.
  if grep -q "command yazi" "$REPO_ROOT/config/zsh/aliases.zsh" 2>/dev/null; then
    report alias "y -> yazi (cwd-aware wrapper)"
  else
    report missing "y wrapper in managed zsh aliases"
  fi
}
