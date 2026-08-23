if command -v brew >/dev/null 2>&1; then
  fzf_prefix="$(brew --prefix fzf 2>/dev/null || true)"
  if [[ -n "$fzf_prefix" ]]; then
    [[ -r "$fzf_prefix/shell/key-bindings.zsh" ]] && source "$fzf_prefix/shell/key-bindings.zsh"
    [[ -r "$fzf_prefix/shell/completion.zsh" ]] && source "$fzf_prefix/shell/completion.zsh"
  fi
  unset fzf_prefix
fi

command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v starship >/dev/null && eval "$(starship init zsh)"
if command -v uv >/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
fi
