readonly CURSOR_CONFIG_HOME="$HOME/Library/Application Support/Cursor/User"
readonly CURSOR_SETTINGS_SOURCE="$REPO_ROOT/config/cursor/settings.json"
readonly CURSOR_SETTINGS_TARGET="$CURSOR_CONFIG_HOME/settings.json"
readonly CURSOR_KEYBINDINGS_SOURCE="$REPO_ROOT/config/cursor/keybindings.json"
readonly CURSOR_KEYBINDINGS_TARGET="$CURSOR_CONFIG_HOME/keybindings.json"

# Cursor's allowlist is intentionally independent from VS Code's.
readonly CURSOR_EXTENSIONS=(
  vscodevim.vim
  raunofreiberg.vesper
  anysphere.remote-containers
  anysphere.remote-ssh
  pomdtr.excalidraw-editor
  GitHub.vscode-pull-request-github
  GitHub.vscode-github-actions
)

cursor_app_installed() {
  command -v cursor >/dev/null 2>&1 || [[ -d "/Applications/Cursor.app" ]]
}

cursor_cli() {
  if command -v cursor >/dev/null 2>&1; then
    command -v cursor
  elif [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
    printf '%s\n' "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
  else
    return 1
  fi
}

cursor_extension_installed() {
  local ext_id="$1" cursor_bin
  cursor_bin="$(cursor_cli)" || return 1
  "$cursor_bin" --list-extensions 2>/dev/null | grep -Fixq "$ext_id"
}

link_cursor_config() {
  link_config "$CURSOR_SETTINGS_SOURCE" "$CURSOR_SETTINGS_TARGET"
  link_config "$CURSOR_KEYBINDINGS_SOURCE" "$CURSOR_KEYBINDINGS_TARGET"
}

install_cursor_extensions() {
  local cursor_bin
  cursor_bin="$(cursor_cli)" || { log 'Cursor CLI unavailable; skipping extension installs'; return; }
  local ext
  for ext in "${CURSOR_EXTENSIONS[@]}"; do
    if cursor_extension_installed "$ext"; then
      log "Cursor extension $ext already installed"
    else
      run "$cursor_bin" --install-extension "$ext"
    fi
  done
}

install_cursor() {
  if ! cursor_app_installed && ! $DRY_RUN; then
    die 'Cursor is missing; run the homebrew phase first'
  fi
  if ! cursor_app_installed && $DRY_RUN; then
    log 'Cursor is not installed; would still link managed configuration'
  fi

  link_cursor_config
  install_cursor_extensions
}

show_cursor_status() {
  printf 'Cursor:\n'
  if cursor_app_installed; then
    printf '  [ok]      Cursor\n'
  else
    printf '  [missing] Cursor\n'
  fi

  local target source resolved
  for target in "$CURSOR_SETTINGS_TARGET" "$CURSOR_KEYBINDINGS_TARGET"; do
    case "$target" in
      "$CURSOR_SETTINGS_TARGET") source="$CURSOR_SETTINGS_SOURCE" ;;
      "$CURSOR_KEYBINDINGS_TARGET") source="$CURSOR_KEYBINDINGS_SOURCE" ;;
    esac
    resolved=""
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
  done

  local ext
  for ext in "${CURSOR_EXTENSIONS[@]}"; do
    if cursor_extension_installed "$ext"; then
      printf '  [ok]      extension %s\n' "$ext"
    else
      printf '  [missing] extension %s\n' "$ext"
    fi
  done
}
