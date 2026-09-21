install_ollama() {
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
