readonly ZED_CONFIG_HOME="$HOME/.config/zed"
readonly ZED_SETTINGS_SOURCE="$REPO_ROOT/config/zed/settings.json"
readonly ZED_SETTINGS_TARGET="$ZED_CONFIG_HOME/settings.json"
readonly ZED_THEME_SOURCE="$REPO_ROOT/config/zed/themes/vesper.json"
readonly ZED_THEME_TARGET="$ZED_CONFIG_HOME/themes/vesper.json"
readonly ZED_KEYMAP_SOURCE="$REPO_ROOT/config/zed/keymap.json"
readonly ZED_KEYMAP_TARGET="$ZED_CONFIG_HOME/keymap.json"

zed_app_installed() {
  command -v zed >/dev/null 2>&1 || [[ -d "/Applications/Zed.app" ]]
}

link_zed_config() {
  link_config "$ZED_SETTINGS_SOURCE" "$ZED_SETTINGS_TARGET"
  link_config "$ZED_THEME_SOURCE" "$ZED_THEME_TARGET"
  link_config "$ZED_KEYMAP_SOURCE" "$ZED_KEYMAP_TARGET"
}

install_zed() {
  if ! zed_app_installed && ! $DRY_RUN; then
    die 'Zed is missing; run the homebrew phase first'
  fi
  if ! zed_app_installed && $DRY_RUN; then
    log 'Zed is not installed; would still link managed configuration'
  fi

  link_zed_config
}

show_zed_status() {
  printf 'Zed:\n'
  if zed_app_installed; then
    printf '  [ok]      Zed\n'
  else
    printf '  [missing] Zed\n'
  fi

  local target source resolved
  for target in "$ZED_SETTINGS_TARGET" "$ZED_THEME_TARGET" "$ZED_KEYMAP_TARGET"; do
    source=""
    case "$target" in
      "$ZED_SETTINGS_TARGET") source="$ZED_SETTINGS_SOURCE" ;;
      "$ZED_THEME_TARGET") source="$ZED_THEME_SOURCE" ;;
      "$ZED_KEYMAP_TARGET") source="$ZED_KEYMAP_SOURCE" ;;
    esac
    resolved=""
    if [[ -L "$target" ]]; then
      resolved="$(readlink -f -- "$target" 2>/dev/null || true)"
    fi
    if [[ -n "$source" && "$resolved" == "$(readlink -f -- "$source" 2>/dev/null || true)" ]]; then
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
  done
}
