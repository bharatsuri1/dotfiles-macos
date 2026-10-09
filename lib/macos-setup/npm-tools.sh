readonly NPM_TOOLS=(
  pnpm
  opencode-ai
  @openai/codex
  @earendil-works/pi-coding-agent
  @devcontainers/cli
)

npm_tool_installed() {
  local name="$1"
  mise exec node@latest -- npm list --global --depth=0 "$name" >/dev/null 2>&1
}

install_npm_tools() {
  section "npm tools"
  if ! command -v mise >/dev/null 2>&1; then
    if $DRY_RUN; then
      log 'Mise is not on PATH; would still install global tools'
    else
      die 'Mise is missing; run the homebrew and mise phases first'
    fi
  fi

  local tool
  for tool in "${NPM_TOOLS[@]}"; do
    if command -v mise >/dev/null 2>&1 && npm_tool_installed "$tool"; then
      log "npm global tool $tool already installed"
      continue
    fi
    # Suppress lifecycle scripts only for @earendil-works/pi-coding-agent, whose
    # dependencies include packages with postinstall hooks that fail or are
    # unnecessary in a global install. Other tools (e.g. opencode-ai) require
    # their postinstall to download or wire up a platform binary, so they must
    # install normally. This matches the Fedora policy.
    if [[ "$tool" == @earendil-works/pi-coding-agent ]]; then
      run mise exec node@latest -- npm install -g --ignore-scripts "$tool"
    else
      run mise exec node@latest -- npm install -g "$tool"
    fi
  done
}

show_npm_tools_status() {
  section "npm tools"
  local item
  for item in "${NPM_TOOLS[@]}"; do
    if command -v mise >/dev/null 2>&1 && npm_tool_installed "$item"; then
      report ok "$item"
    else
      report missing "$item"
    fi
  done
}

update_npm_tools() {
  section "npm updates"
  command -v mise >/dev/null 2>&1 || die 'Mise is missing; run the setup runtime phase first'
  local tool
  for tool in "${NPM_TOOLS[@]}"; do
    if ! mise exec node@latest -- npm list --global --depth=0 "$tool" >/dev/null 2>&1; then
      report missing "$tool is not installed; run setup to install managed npm tools"
      continue
    fi
    log "updating managed npm tool $tool"
    if [[ "$tool" == @earendil-works/pi-coding-agent ]]; then
      run mise exec node@latest -- npm install --global --ignore-scripts "$tool@latest"
    else
      run mise exec node@latest -- npm install --global "$tool@latest"
    fi
  done
}
