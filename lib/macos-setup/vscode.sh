readonly VSCODE_CONFIG_HOME="$HOME/Library/Application Support/Code/User"
readonly VSCODE_SETTINGS_SOURCE="$REPO_ROOT/config/vscode/settings.json"
readonly VSCODE_SETTINGS_TARGET="$VSCODE_CONFIG_HOME/settings.json"
readonly VSCODE_KEYBINDINGS_SOURCE="$REPO_ROOT/config/vscode/keybindings.json"
readonly VSCODE_KEYBINDINGS_TARGET="$VSCODE_CONFIG_HOME/keybindings.json"

# Reviewed extension allowlist (kept in sync with dotfiles-fedora).
readonly VSCODE_EXTENSIONS=(
  vscodevim.vim
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  GitHub.vscode-pull-request-github
  ms-vscode.remote-explorer
  openai.chatgpt
  raunofreiberg.vesper
  ms-azuretools.vscode-docker
  ms-vscode-remote.remote-containers
  ms-azuretools.vscode-containers
  GitHub.vscode-github-actions
  sst-dev.opencode
)

vscode_app_installed() {
  command -v code >/dev/null 2>&1 || [[ -d "/Applications/Visual Studio Code.app" ]]
}

vscode_cli() {
  if command -v code >/dev/null 2>&1; then
    command -v code
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    printf '%s\n' "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  else
    return 1
  fi
}

vscode_extension_installed() {
  local ext_id="$1" code_bin
  code_bin="$(vscode_cli)" || return 1
  "$code_bin" --list-extensions 2>/dev/null | grep -Fixq "$ext_id"
}

link_vscode_config() {
  link_config "$VSCODE_SETTINGS_SOURCE" "$VSCODE_SETTINGS_TARGET"
  link_config "$VSCODE_KEYBINDINGS_SOURCE" "$VSCODE_KEYBINDINGS_TARGET"
}

install_vscode_extensions() {
  local code_bin
  code_bin="$(vscode_cli)" || { log 'VS Code CLI unavailable; skipping extension installs'; return; }
  local ext
  for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if vscode_extension_installed "$ext"; then
      log "VS Code extension $ext already installed"
    else
      run "$code_bin" --install-extension "$ext"
    fi
  done
}

install_vscode() {
  if ! vscode_app_installed && ! $DRY_RUN; then
    die 'VS Code is missing; run the homebrew phase first'
  fi
  if ! vscode_app_installed && $DRY_RUN; then
    log 'VS Code is not installed; would still link managed configuration'
  fi

  link_vscode_config
  install_vscode_extensions
}
