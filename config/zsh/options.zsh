HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE AUTO_CD INTERACTIVE_COMMENTS NO_BEEP

# 10ms ESC timeout so vi-mode mode switches feel instant; the 400ms zsh
# default makes Esc-to-normal-mode laggy. Arrow and other multi-byte keys
# still resolve because their trailing bytes arrive within 10ms.
KEYTIMEOUT=1
