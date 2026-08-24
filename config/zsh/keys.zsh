# ZLE keybindings that supplement vi-mode defaults with macOS-style word
# deletion. Vi insert mode is the default keymap on this system, and the
# Option-key word-editing bindings are absent from zsh's vi keymap and from
# /etc/zshrc (which only binds plain Delete to delete-char). With Ghostty's
# macos-option-as-alt = true, Option sends an Alt/Meta modifier, so we bind
# both the CSI-modifier encoding (^[[3;3~) and the ESC-prefixed meta encoding
# (^[^[[3~) to cover how different terminals deliver the key.

# Bind in both viins (the default main keymap) and emacs (kept for parity so
# the bindings survive if the keymap ever switches).
local keymap
for keymap in viins emacs; do
  # Option-Delete: delete the word to the right of the cursor.
  bindkey -M "$keymap" '^[[3;3~' kill-word
  bindkey -M "$keymap" '^[^[[3~' kill-word
  # Option-Backspace: delete the word to the left of the cursor.
  bindkey -M "$keymap" '^[^?' backward-kill-word
  bindkey -M "$keymap" '^[^H' backward-kill-word
done
unset keymap

# Vi-mode per-keymap cursor shape via DECSCUSR. Match the VS Code vim
# settings (block for normal, line for insert) so the terminal and editor
# agree on what each mode looks like. Ghostty supports DECSCUSR; the
# sequences here override config/ghostty/config's cursor-style while zle is
# active, and zle-line-finish restores a steady block when leaving the line
# editor so commands run between prompts see a normal cursor.
local _vi_cursor_block=$'\e[2 q'   # steady block -> vicmd (normal)
local _vi_cursor_line=$'\e[6 q'    # steady bar   -> viins (insert)

zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then
    printf '%s' "$_vi_cursor_block"
  else
    printf '%s' "$_vi_cursor_line"
  fi
}
zle -N zle-keymap-select

# Start each edit line in insert shape and restore a block when leaving the
# line editor so prompts from other programs see a normal cursor.
zle-line-init()   { printf '%s' "$_vi_cursor_line" }
zle-line-finish() { printf '%s' "$_vi_cursor_block" }
zle -N zle-line-init
zle -N zle-line-finish
unset _vi_cursor_block _vi_cursor_line
