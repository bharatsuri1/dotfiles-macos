zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

if command -v brew >/dev/null 2>&1; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
