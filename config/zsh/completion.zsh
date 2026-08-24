zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
# fzf-tab (sourced later in plugins.zsh) takes over the completion menu and
# renders an fzf picker; menu select is kept as the fallback when fzf-tab is
# absent so completion still gets an interactive, highlighted column list.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

if command -v brew >/dev/null 2>&1; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
