readonly NVIM_CONFIG_SOURCE="$REPO_ROOT/config/nvim"
readonly NVIM_CONFIG_TARGET="$HOME/.config/nvim"

nvim_installed() {
  command -v nvim >/dev/null 2>&1
}

install_nvim() {
  if ! nvim_installed && ! $DRY_RUN; then
    die 'Neovim is missing; run the homebrew phase first'
  fi
  if ! nvim_installed && $DRY_RUN; then
    log 'Neovim is not installed; would still link managed configuration'
  fi

  link_config "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_TARGET"
}
