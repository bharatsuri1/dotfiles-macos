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
  local target
  for target in \
    "$HOME/.zshenv" \
    "$HOME/.config/zsh/.zshrc" \
    "$HOME/.config/zsh/aliases.zsh" \
    "$HOME/.config/zsh/completion.zsh" \
    "$HOME/.config/zsh/integrations.zsh" \
    "$HOME/.config/zsh/options.zsh" \
    "$HOME/.config/zsh/plugins.zsh" \
    "$HOME/.config/zsh/keys.zsh" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/bat/config" \
    "$HOME/.config/tmux/tmux.conf" \
    "$HOME/.config/tmux/status.conf" \
    "$HOME/.config/sesh/sesh.toml" \
    "$HOME/.config/atuin/config.toml" \
    "$HOME/.config/mise/config.toml" \
    "$HOME/.config/ghostty/config" \
    "$HOME/.config/ghostty/themes/Vesper" \
    "$HOME/.config/fastfetch/config.jsonc" \
    "$HOME/.config/herdr/config.toml" \
    "$HOME/.config/nvim" \
    "$HOME/.config/yazi" \
    "$HOME/.pi/agent/settings.json" \
    "$HOME/.pi/agent/extensions/statusline.ts" \
    "$HOME/.codex/dotfiles.config.toml" \
    "$HOME/.config/opencode/opencode.jsonc" \
    "$HOME/.config/opencode/tui.jsonc" \
    "$HOME/.config/opencode/herdr-tui-session.js" \
    "$HOME/.local/bin/macos-update" \
    "$REPO_ROOT/.git/hooks/pre-commit" \
    "$VSCODE_SETTINGS_TARGET" \
    "$VSCODE_KEYBINDINGS_TARGET" \
    "$CURSOR_SETTINGS_TARGET" \
    "$CURSOR_KEYBINDINGS_TARGET" \
    "$ZED_SETTINGS_TARGET" \
    "$ZED_THEME_TARGET" \
    "$ZED_KEYMAP_TARGET"; do
    if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$REPO_ROOT"/* ]]; then
      report linked "$target"
    else
      report local "$target"
    fi
  done
}
