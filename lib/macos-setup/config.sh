install_config() {
  section Config
  link_config "$REPO_ROOT/config/starship.toml" "$HOME/.config/starship.toml"
  link_config "$REPO_ROOT/config/bat/config" "$HOME/.config/bat/config"
  link_config "$REPO_ROOT/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  link_config "$REPO_ROOT/config/tmux/status.conf" "$HOME/.config/tmux/status.conf"
  link_config "$REPO_ROOT/config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"
  link_config "$REPO_ROOT/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  link_config "$REPO_ROOT/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  link_config "$REPO_ROOT/config/mise/config.toml" "$HOME/.config/mise/config.toml"
  link_config "$REPO_ROOT/config/ghostty/config" "$HOME/.config/ghostty/config"
  link_config "$REPO_ROOT/config/ghostty/themes/Vesper" "$HOME/.config/ghostty/themes/Vesper"
  link_config "$REPO_ROOT/bin/macos-update" "$HOME/.local/bin/macos-update"
  link_config "$REPO_ROOT/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  link_config "$REPO_ROOT/config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
  remove_managed_herdr_plugin_link
  link_config "$REPO_ROOT/config/pi/settings.json" "$HOME/.pi/agent/settings.json"
  link_config "$REPO_ROOT/config/pi/extensions/statusline.ts" "$HOME/.pi/agent/extensions/statusline.ts"
  link_config "$REPO_ROOT/config/codex/dotfiles.config.toml" "$HOME/.codex/dotfiles.config.toml"
  install_repo_hook
}

# Herdr owns and updates its OpenCode integration. Remove only the legacy
# link to this checkout; preserve real files and links owned elsewhere.
remove_managed_herdr_plugin_link() {
  local target="$HOME/.config/opencode/herdr-tui-session.js"
  local link_target=''
  if [[ -L "$target" ]]; then
    link_target="$(readlink "$target")"
  fi
  if [[ "$link_target" == "$REPO_ROOT/config/opencode/herdr-tui-session.js" ]]; then
    run rm -- "$target"
    log "removed repo-managed link $target; herdr owns its opencode integration"
  fi
}

repo_hook_path() {
  [[ -e "$REPO_ROOT/.git" ]] || return 1
  local hook_path
  hook_path="$(git -C "$REPO_ROOT" rev-parse --git-path hooks/pre-commit)" || return 1
  if [[ "$hook_path" != /* ]]; then
    hook_path="$REPO_ROOT/$hook_path"
  fi
  printf '%s\n' "$hook_path"
}

install_repo_hook() {
  local hook_path
  if ! hook_path="$(repo_hook_path)"; then
    report local 'skipping pre-commit hook; this checkout has no Git metadata'
    return
  fi
  link_config "$REPO_ROOT/hooks/pre-commit" "$hook_path"
}
