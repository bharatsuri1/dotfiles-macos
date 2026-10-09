show_status() {
  section Machine
  report ok "$(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))"
  report local "checkout $REPO_ROOT"
  report local "login shell ${SHELL:-unknown}"

  ensure_brew_on_path
  section Homebrew
  if command -v brew >/dev/null 2>&1; then
    report ok "$(brew --version | head -n 1)"
    if brew bundle check --file "$REPO_ROOT/Brewfile" >/dev/null 2>&1; then
      report ok "Brewfile satisfied"
    else
      report missing "Brewfile unmet; run macos-setup homebrew"
    fi
  else
    report missing "Homebrew"
  fi

  show_ollama_status

  section Mise
  if mise_installed; then
    report ok "$(command -v mise)"
  else
    report missing "mise"
  fi

  show_npm_tools_status

  show_herdr_status

  show_nvim_status

  show_vscode_status

  show_cursor_status

  show_zed_status

  show_yazi_status

  show_macos_defaults_status

  show_chrome_defaults_status

  section "Zsh plugins"
  local plugin revision destination
  while read -r plugin revision; do
    destination="$ZSH_PLUGIN_ROOT/$plugin"
    if [[ -d "$destination/.git" ]] &&
      [[ "$(git -C "$destination" rev-parse HEAD 2>/dev/null || true)" == "$revision" ]]; then
      report pinned "$plugin @ ${revision:0:7}"
    else
      report missing "$plugin @ ${revision:0:7}"
    fi
  done <<EOF
zsh-autosuggestions $AUTOSUGGESTIONS_REVISION
fast-syntax-highlighting $SYNTAX_HIGHLIGHTING_REVISION
fzf-tab $FZF_TAB_REVISION
zsh-history-substring-search $HISTORY_SUBSTRING_SEARCH_REVISION
EOF

  section Configuration
  show_pi_settings_status
  local hook_path
  if hook_path="$(repo_hook_path)"; then
    show_config_link_status "$REPO_ROOT/hooks/pre-commit" "$hook_path"
  fi
  local -a config_links=(
    "$REPO_ROOT/config/zsh/zshenv" "$HOME/.zshenv"
    "$REPO_ROOT/config/zsh/zshrc" "$HOME/.config/zsh/.zshrc"
    "$REPO_ROOT/config/zsh/aliases.zsh" "$HOME/.config/zsh/aliases.zsh"
    "$REPO_ROOT/config/zsh/completion.zsh" "$HOME/.config/zsh/completion.zsh"
    "$REPO_ROOT/config/zsh/integrations.zsh" "$HOME/.config/zsh/integrations.zsh"
    "$REPO_ROOT/config/zsh/options.zsh" "$HOME/.config/zsh/options.zsh"
    "$REPO_ROOT/config/zsh/plugins.zsh" "$HOME/.config/zsh/plugins.zsh"
    "$REPO_ROOT/config/zsh/keys.zsh" "$HOME/.config/zsh/keys.zsh"
    "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
    "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
    "$REPO_ROOT/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    "$REPO_ROOT/config/tmux/status.conf" "$HOME/.config/tmux/status.conf"
    "$REPO_ROOT/config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"
    "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
    "$REPO_ROOT/config/mise/config.toml" "$HOME/.config/mise/config.toml"
    "$REPO_ROOT/config/ghostty/config" "$HOME/.config/ghostty/config"
    "$REPO_ROOT/config/ghostty/themes/Vesper" "$HOME/.config/ghostty/themes/Vesper"
    "$REPO_ROOT/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    "$REPO_ROOT/config/pi/extensions/statusline.ts" "$HOME/.pi/agent/extensions/statusline.ts"
    "$REPO_ROOT/config/codex/dotfiles.config.toml" "$HOME/.codex/dotfiles.config.toml"
    "$REPO_ROOT/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    "$REPO_ROOT/config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
    "$REPO_ROOT/bin/macos-update" "$HOME/.local/bin/macos-update"
  )
  local index
  for ((index = 0; index < ${#config_links[@]}; index += 2)); do
    show_config_link_status "${config_links[index]}" "${config_links[index + 1]}"
  done
}
