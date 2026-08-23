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
    else
      # Use --ignore-scripts to keep installer hooks from executing; the tools we
      # install are pure-JS CLIs that do not need postinstall.
      run npm install -g --ignore-scripts "$tool"
    fi
  done
}
