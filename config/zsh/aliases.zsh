alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'
alias mkdir='mkdir -p'
alias which='type -a'
alias path='print -l $path'
alias reload='exec zsh'
alias tl='sesh picker'
alias tk='tmux kill-server'
alias afk='pmset displaysleepnow'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles true && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles false && killall Finder'

t() {
  local session_name="${1:-home}"

  if [[ -n "$TMUX" ]]; then
    tmux has-session -t "=$session_name" 2>/dev/null ||
      tmux new-session -d -s "$session_name" -c "$HOME"
    tmux switch-client -t "=$session_name"
  else
    tmux new-session -A -s "$session_name" -c "$HOME"
  fi
}

if command -v eza >/dev/null; then
  alias l='eza -lah --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto'
  alias la='eza -a --group-directories-first --icons=auto'
  alias tree='eza --tree --group-directories-first --icons=auto'
fi

if command -v bat >/dev/null; then
  alias cat='bat'
  alias catp='bat --plain --paging=never'
fi

command -v df >/dev/null && alias df='df -h'
command -v du >/dev/null && alias du='du -h'
command -v nvim >/dev/null && alias v='nvim'
command -v lazygit >/dev/null && alias lg='lazygit'
command -v lazydocker >/dev/null && alias ld='lazydocker'

if command -v git >/dev/null; then
  alias g='git'
  alias gd='git diff'
  alias gds='git diff --staged'
  alias glog='git log --oneline --graph --decorate'
  alias gs='git status --short --branch'
fi

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

# Keep the system awake until Ctrl-C, or wrap a command with `caffeinate -dims`.
caffeinate-wrapper() {
  if (( $# )); then
    caffeinate -dims "$@"
  else
    caffeinate -dims
  fi
}
alias caffeinate='caffeinate-wrapper'
