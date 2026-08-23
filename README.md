# macOS laptop setup

An idempotent, inspectable setup CLI and portable configuration for the macOS
laptop. It safely detects and preserves work already done on the machine. It
does not own OS installation, disk layout, secrets, or application state.

The package ownership is intentionally simple: Homebrew owns every managed
tool and application through the repository's `Brewfile`.

## One-line bootstrap

From any macOS installation with working networking, run:

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-macos/main/bootstrap.sh | bash
```

The bootstrap requests the Xcode Command Line Tools installation when git is
unavailable, clones this repository under `~/.local/share/dotfiles-macos`,
configures Git defaults, and starts the guided setup. Set
`DOTFILES_MACOS_INSTALL_ROOT` or `DOTFILES_MACOS_REPOSITORY_URL` before the
command to override the checkout location or repository URL.

To exercise the hosted bootstrap without changing the machine:

```bash
curl -fsSL https://raw.githubusercontent.com/bharatsuri1/dotfiles-macos/main/bootstrap.sh \
  | bash -s -- --dry-run apply
```

## CLI

After bootstrapping, rerun the complete setup from the checkout with:

```bash
./bin/macos-setup
```

Inspect what is already complete with:

```bash
./bin/macos-setup status
```

Preview all missing work without changing the machine:

```bash
./bin/macos-setup --dry-run apply
```

Each phase can also run independently:

```bash
./bin/macos-setup homebrew
./bin/macos-setup shell-tools
./bin/macos-setup shell
./bin/macos-setup config
./bin/macos-setup nvim
./bin/macos-setup vscode
./bin/macos-setup yazi
```

Configuration deployment uses symlinks back into this checkout. An existing
target is moved first to a timestamped directory under
`~/.local/state/dotfiles-macos/backups/`; it is never silently overwritten.

## Shell

The managed Zsh setup keeps durable configuration under `config/zsh/` with
`ZDOTDIR=~/.config/zsh`. Homebrew-aware completion and fzf integration load
from the active `brew --prefix`. Starship renders the prompt, Atuin keeps
history local-only, and two pinned direct-sourced plugins
(`zsh-autosuggestions` and `fast-syntax-highlighting`) replace any plugin
manager. Machine-local overrides belong in `~/.zshenv.local` and
`~/.config/zsh/local.zsh`, both optional and ignored by Git.

## Managed configuration

Beyond the shell, the `config` phase currently links Starship, bat, tmux +
Sesh (with a Vesper status bar and `Ctrl+Space` prefix), Atuin (local-only
history), and Ghostty (Rose Pine, JetBrainsMono Nerd Font 14, macOS-native
window chrome with `Opt` as `Alt`). Tmux copies selections to the macOS
clipboard with `pbcopy`, and `Prefix b` opens the Sesh session picker while
`Prefix Tab` switches to the previous session.

## Editors

The `nvim` phase links a managed LazyVim configuration with the self-contained
Vesper colorscheme, matching the terminal palette. The `vscode` phase links a
Vesper-themed settings.json and macOS keybindings into
`~/Library/Application Support/Code/User/` and installs the reviewed extension
allowlist (Vim, remote SSH/containers, ChatGPT, OpenCode, Vesper theme, and
GitHub integrations). VS Code's Ghostty integration is preconfigured via
`terminal.external.osxExec`.

## Yazi

The `yazi` phase links the managed configuration at `config/yazi/` —
`yazi.toml`, `keymap.toml`, `theme.toml`, `package.toml`, and the
self-contained Vesper flavor at `flavors/vesper.yazi/` — into
`~/.config/yazi/`. The Vesper flavor covers manager, tabs, mode, status,
pick, input, cmp, tasks, which, help, spot, notify, filetype, and icon
sections using the palette shared with Zed, Neovim, Alacritty, and
Quickshell. The `y` shell wrapper (in `config/zsh/aliases.zsh`) changes the
shell's working directory on Yazi exit (press `q` to accept, `Q` to stay).

## Scope

Setup milestones are planned in
[GitHub Issues](https://github.com/bharatsuri1/dotfiles-macos/issues) and are
added one approved component at a time. The legacy macOS setup at
https://github.com/bharatsuri1/dotfiles is reference only and not a source of
truth.

Authentication, shell history, SSH keys, application credentials, caches, and
generated runtime files must stay outside Git.
