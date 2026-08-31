# Tool ownership and cross-platform parity

This document records which tools are shared across `dotfiles-macos` and
`dotfiles-fedora` (same config, same role) versus platform-native, and audits
developer CLI package parity between the two Brewfiles / package lists.

It exists so that future additions go to the right repo and drift between the
two setups is intentional rather than accidental.

## Ownership model

`dotfiles-macos` and `dotfiles-fedora` are **independent repos**, not a
monorepo with shared submodules. Each repo owns its complete setup CLI and
configuration. When a tool's config is platform-neutral, the file content is
duplicated in both repos and reconciled by hand (diffed against the other repo
as the baseline). No shared symlink or submodule couples them.

### Shared tools (same config content in both repos)

| Tool | Config path | Notes |
|------|-------------|-------|
| Starship | `config/starship.toml` | Byte-for-byte identical |
| bat | `config/bat/config` | Identical |
| Atuin | `config/atuin/config.toml` | Identical |
| mise | `config/mise/config.toml` | Both set `[tools] node = "latest"` |
| Tmux | `config/tmux/tmux.conf` | Identical except macOS uses `pbcopy`, Fedora uses `wl-copy` |
| Tmux status | `config/tmux/status.conf` | Identical (Vesper powerline pills) |
| Sesh | `config/sesh/sesh.toml` | Identical |
| Neovim (LazyVim) | `config/nvim/` | Separate lockfiles by design (see below) |
| VS Code settings | `config/vscode/settings.json` | Vim keybindings identical; terminal profiles and external-terminal settings are platform-specific |
| Codex profile | `config/codex/dotfiles.config.toml` | Identical |
| Pi settings | `config/pi/settings.json` | May drift independently (runtime model/provider switches) |
| Pi statusline | `config/pi/extensions/statusline.ts` | Identical |
| Fastfetch | `config/fastfetch/config.jsonc` | Identical (fastfetch does OS detection internally) |

### Platform-native tools (exist on one repo only)

**macOS-only** (no Fedora equivalent, or macOS-specific role):

| Tool | Why platform-native |
|------|---------------------|
| Ghostty | macOS cask; Fedora uses Alacritty (dnf) |
| Yazi | macOS-only file manager for now (managed `config/yazi/` with the Vesper flavor and the `y` cwd-aware shell wrapper); no Fedora equivalent yet |
| 1Password, Raycast, Notion, Cleanshot, Homerow, Little Snitch, Logi Options+, Vial, Bazecor, Alcove, Antinote, Handy, Stats | macOS-only GUI applications |
| `pmset` alias (`afk`) | macOS power management |
| `defaults write` aliases (`showfiles`/`hidefiles`) | macOS Finder |
| `caffeinate` wrapper | macOS has a native `caffeinate`; Fedora uses `systemd-inhibit` |
| `pinentry-mac` | macOS-specific GPG pinentry |
| VS Code `terminal.external.osxExec` | macOS-specific VS Code setting |

**Fedora-only** (no macOS equivalent, or Linux-specific role):

| Tool | Why platform-native |
|------|---------------------|
| Alacritty | Fedora terminal (dnf) |
| niri, SwayNC, Quickshell, SDDM, gtklock | Wayland desktop session |
| keyd | Linux keyboard remapping |
| voxtype, vicinae | Fedora input method daemons |
| diskonaut, powertop, systemctl-tui, bandwhich, batctl | Linux system tools (systemd, power, battery) |
| wiremix, wlctl, bluetui | Linux audio/Bluetooth TUIs |
| grim, slurp | Wayland screenshot tools |
| Zed | Fedora installs Zed as a Flatpak; macOS does not install Zed |

### Deliberately divergent

| Area | macOS | Fedora | Reason |
|------|-------|--------|--------|
| VS Code `keybindings.json` | `cmd+` keys (navigate, code nav, tasks) | `ctrl+` keys (copy/cut/paste, quickOpen, terminal, sidebar) | macOS reserves `ctrl+` for emacs-style text navigation; `cmd+` is the macOS convention. Fedora uses `ctrl+` as the Linux convention. |
| VS Code terminal profile | `zsh -l` (native login shell) | `flatpak-spawn --host zsh` (VS Code runs as a Flatpak) | Fedora VS Code is sandboxed; needs host spawn |
| Zsh `codex` aliases | `cx`/`sol`/`terra` without bypass flags | `cx`/`sol`/`terra` with `--dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust` | macOS retains Codex safety guardrails; Fedora opts into fully autonomous mode |
| Neovim lockfile | `config/nvim/lazy-lock.json` (macOS) | `config/nvim/lazy-lock.json` (Fedora) | Separate dotfiles; lockfiles are gitignored-by-design per the user and are not reconciled |
| `lazyvim.json` | Retained (macOS-only, gitignored) | Not present | macOS-specific snapshot; gitignored by design |

## Developer CLI package parity audit

### In parity (installed on both platforms)

| Tool | macOS source | Fedora source |
|------|-------------|---------------|
| fd | `brew fd` | `dnf fd-find` |
| ripgrep | `brew ripgrep` | `dnf ripgrep` |
| fzf | `brew fzf` | `dnf fzf` |
| eza | `brew eza` | `dnf eza` |
| bat | `brew bat` | `dnf bat` |
| zoxide | `brew zoxide` | `dnf zoxide` |
| starship | `brew starship` | `linuxbrew starship` |
| gum | `brew gum` | `dnf gum` |
| atuin | `brew atuin` | `dnf atuin` |
| tmux | `brew tmux` | `dnf tmux` |
| sesh | `brew sesh` | `linuxbrew sesh` |
| btop | `brew btop` | `dnf btop` |
| fastfetch | `brew fastfetch` | `dnf fastfetch` |
| lazygit | `brew lazygit` | `linuxbrew lazygit` |
| lazydocker | `brew lazydocker` | `linuxbrew lazydocker` |
| gh | `brew gh` | `dnf gh` |
| jless | `brew jless` | `linuxbrew jless` |
| xh | `brew xh` | `linuxbrew xh` |
| neovim | `brew neovim` | `dnf neovim` |
| uv | `brew uv` | `dnf uv` (development phase) |
| mise | `brew mise` | `dnf mise` (development phase) |
| @openai/codex | `npm -g` | `npm -g` (mise node) |
| opencode-ai | `npm -g` | `npm -g` (mise node) |
| @earendil-works/pi-coding-agent | `npm -g --ignore-scripts` | `npm -g --ignore-scripts` (mise node) |

### macOS-only (in Brewfile, no Fedora equivalent)

These are legitimate macOS additions — most are general-purpose developer CLIs
that could also be useful on Fedora but are not yet in the Fedora repo. They
are not regressions; adding them to Fedora is a future decision, not a parity
gap that blocks macOS.

`htop`, `jq`, `direnv`, `wget`, `tree`, `hyperfine`, `glow`, `pnpm` (npm),
`k9s`, `lnav`, `logdy`, `lazysql`, `hl`, `television`, `yazi`, `sevenzip`,
`vivid`, `bash-completion`, `allure`, `ffmpeg-full`, `imagemagick-full`,
`poppler`, `resvg`

### Fedora-only (not on macOS)

| Tool | Applicable to macOS? |
|------|---------------------|
| `ollama` | No — intentionally removed from the macOS Brewfile |
| `diskonaut` | Yes — available on Homebrew |
| `powertop` | No — Linux power tool |
| `systemctl-tui` | No — systemd-specific |
| `bandwhich` | Yes — available on Homebrew (cross-platform Rust) |
| `batctl` | No — Linux battery threshold manager |
| `wiremix` / `wlctl` / `bluetui` | No — Linux audio/Bluetooth |

### Conclusion

Core developer CLI parity is solid — every shared tool that both setups need
is present on both. The macOS Brewfile carries a broader set of convenience
CLIs (jq, direnv, hyperfine, k9s, lnav, etc.) that Fedora could adopt over
time. Fedora's Linux-specific system tools (powertop, systemctl-tui, batctl)
have no macOS equivalent and never will. The remaining Fedora developer CLIs
that could reasonably be added to macOS are `diskonaut` and `bandwhich`; this
is deferred pending explicit desire to use them on macOS.
