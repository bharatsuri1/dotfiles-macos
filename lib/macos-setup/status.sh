show_status() {
  printf 'macOS: %s %s (%s)\n' "$(sw_vers -productName)" "$(sw_vers -productVersion)" "$(uname -m)"
  printf 'Checkout: %s\n' "$REPO_ROOT"
  printf 'Login shell: %s\n' "${SHELL:-unknown}"

  ensure_brew_on_path
  printf 'Homebrew:\n'
  if command -v brew >/dev/null 2>&1; then
    printf '  [ok]      %s\n' "$(brew --version | head -n 1)"
    if brew bundle check --file "$REPO_ROOT/Brewfile" >/dev/null 2>&1; then
      printf '  [ok]      Brewfile satisfied\n'
    else
      printf '  [missing] Brewfile unmet; run macos-setup homebrew\n'
    fi
  else
    printf '  [missing] Homebrew\n'
  fi

  printf 'Mise:\n'
  if mise_installed; then
    printf '  [ok]      %s\n' "$(command -v mise)"
  else
    printf '  [missing] mise\n'
  fi

  show_npm_tools_status

  show_herdr_status

  show_nvim_status

  show_vscode_status

  show_yazi_status

  printf 'Zsh plugins:\n'
  local plugin revision destination
  while read -r plugin revision; do
    destination="$ZSH_PLUGIN_ROOT/$plugin"
    if [[ -d "$destination/.git" ]] &&
      [[ "$(git -C "$destination" rev-parse HEAD 2>/dev/null || true)" == "$revision" ]]; then
      printf '  [pinned]  %s @ %s\n' "$plugin" "${revision:0:7}"
    else
      printf '  [missing] %s @ %s\n' "$plugin" "${revision:0:7}"
    fi
  done <<EOF
zsh-autosuggestions $AUTOSUGGESTIONS_REVISION
fast-syntax-highlighting $SYNTAX_HIGHLIGHTING_REVISION
EOF

  printf 'Configuration:\n'
  local target
  for target in \
    "$HOME/.zshenv" \
    "$HOME/.config/zsh/.zshrc" \
    "$HOME/.config/zsh/aliases.zsh" \
    "$HOME/.config/zsh/completion.zsh" \
    "$HOME/.config/zsh/integrations.zsh" \
    "$HOME/.config/zsh/options.zsh" \
    "$HOME/.config/zsh/plugins.zsh" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/bat/config" \
    "$HOME/.config/tmux/tmux.conf" \
    "$HOME/.config/tmux/status.conf" \
    "$HOME/.config/sesh/sesh.toml" \
    "$HOME/.config/atuin/config.toml" \
    "$HOME/.config/mise/config.toml" \
    "$HOME/.config/ghostty/config" \
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
    "$VSCODE_SETTINGS_TARGET" \
    "$VSCODE_KEYBINDINGS_TARGET"; do
    if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$REPO_ROOT"/* ]]; then
      printf '  [linked]  %s\n' "$target"
    else
      printf '  [local]   %s\n' "$target"
    fi
  done
}
