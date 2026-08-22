ensure_backup_dir() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
    run mkdir -p "$BACKUP_DIR"
  fi
}

link_config() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$(readlink -f -- "$source" 2>/dev/null || true)" ]]; then
    log "$target already linked"
    return
  fi

  run mkdir -p "$(dirname -- "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    ensure_backup_dir
    local backup="$BACKUP_DIR/${target#"$HOME"/}"
    run mkdir -p "$(dirname -- "$backup")"
    run mv -- "$target" "$backup"
    log "backed up $target to $backup"
  fi
  run ln -s "$source" "$target"
}

install_shell() {
  link_config "$REPO_ROOT/config/zsh/zshenv" "$HOME/.zshenv"
  link_config "$REPO_ROOT/config/zsh/zshrc" "$HOME/.config/zsh/.zshrc"

  local module
  for module in options completion integrations aliases plugins; do
    link_config "$REPO_ROOT/config/zsh/$module.zsh" "$HOME/.config/zsh/$module.zsh"
  done

  if [[ ! -r "$ZSH_PLUGIN_ROOT/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] ||
    [[ ! -r "$ZSH_PLUGIN_ROOT/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
    log 'pinned Zsh plugins are not installed; run the shell-tools phase first'
  fi
}
