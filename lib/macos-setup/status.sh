show_status() {
  printf 'macOS: %s %s (%s)\n' "$(sw_vers -productName)" "$(sw_vers -productVersion)" "$(uname -m)"
  printf 'Checkout: %s\n' "$REPO_ROOT"
  printf 'Login shell: %s\n' "${SHELL:-unknown}"

  ensure_brew_on_path
  if command -v brew >/dev/null 2>&1; then
    printf 'Homebrew: %s (%s)\n' "$(brew --version | head -n 1)" "$(command -v brew)"
    if brew bundle check --file "$REPO_ROOT/Brewfile" >/dev/null 2>&1; then
      printf 'Brewfile: satisfied\n'
    else
      printf 'Brewfile: unmet; run macos-setup homebrew\n'
    fi
  else
    printf 'Homebrew: not installed\n'
  fi
}
