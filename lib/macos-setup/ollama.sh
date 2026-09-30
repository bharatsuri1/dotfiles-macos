install_ollama() {
  section Ollama
  if ! command -v ollama >/dev/null 2>&1; then
    if $DRY_RUN; then
      log 'ollama is not installed; would start the brew service'
      printf '+ brew services start ollama\n'
      return
    fi
    die 'ollama is missing; run the homebrew phase first'
  fi

  if brew services list 2>/dev/null | awk '$1 == "ollama" && $2 == "started"' | grep -q .; then
    log 'ollama login service already started'
    return
  fi
  log 'starting ollama login service'
  run brew services start ollama
}

show_ollama_status() {
  section Ollama
  if ! command -v ollama >/dev/null 2>&1; then
    report missing "ollama; run macos-setup homebrew"
    return
  fi
  report ok "$(command -v ollama)"
  if brew services list 2>/dev/null | awk '$1 == "ollama" && $2 == "started"' | grep -q .; then
    report ok "login service started"
  else
    report missing "login service; run macos-setup ollama"
  fi
}
