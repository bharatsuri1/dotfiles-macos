readonly NPM_TOOLS=(
  pnpm
  opencode-ai
  @openai/codex
  @earendil-works/pi-coding-agent
)

npm_tool_installed() {
  local name="$1"
  npm ls -g --depth=0 --parseable 2>/dev/null | grep -Fxq "$(npm root -g)/$name"
}

install_npm_tools() {
  if ! command -v npm >/dev/null 2>&1; then
    if $DRY_RUN; then
      log 'npm is not on PATH; would still install global tools'
    else
      die 'npm is missing; run the mise phase first (installs Node.js globally)'
    fi
  fi

  local tool
  for tool in "${NPM_TOOLS[@]}"; do
    if command -v npm >/dev/null 2>&1 && npm_tool_installed "$tool"; then
      log "npm global tool $tool already installed"
      continue
    fi
    # Suppress lifecycle scripts only for @earendil-works/pi-coding-agent, whose
    # dependencies include packages with postinstall hooks that fail or are
    # unnecessary in a global install. Other tools (e.g. opencode-ai) require
    # their postinstall to download or wire up a platform binary, so they must
    # install normally. This matches the Fedora policy.
    if [[ "$tool" == @earendil-works/pi-coding-agent ]]; then
      run npm install -g --ignore-scripts "$tool"
    else
      run npm install -g "$tool"
    fi
  done
}

show_npm_tools_status() {
  printf 'Mise-managed npm tools:\n'
  local item
  for item in "${NPM_TOOLS[@]}"; do
    if command -v npm >/dev/null 2>&1 && npm_tool_installed "$item"; then
      printf '  [ok]      %s\n' "$item"
    else
      printf '  [missing] %s\n' "$item"
    fi
  done
}
