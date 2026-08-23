install_config() {
  link_config "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
  link_config "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
  link_config "$REPO_ROOT/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  link_config "$REPO_ROOT/config/tmux/status.conf" "$HOME/.config/tmux/status.conf"
  link_config "$REPO_ROOT/config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"
  link_config "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  link_config "$REPO_ROOT/config/ghostty/config" "$HOME/.config/ghostty/config"
  link_config "$REPO_ROOT/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  link_config "$REPO_ROOT/config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
  link_config "$REPO_ROOT/config/opencode/herdr-tui-session.js" "$HOME/.config/opencode/herdr-tui-session.js"
}
