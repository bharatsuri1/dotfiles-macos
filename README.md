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

`--dry-run` skips the clone or pull and the global Git identity writes. When the
checkout already exists, the setup phases still preview. When it does not,
bootstrap stops after printing those steps.

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
./bin/macos-setup ollama
./bin/macos-setup macos-defaults
./bin/macos-setup chrome-defaults
./bin/macos-setup shell-tools
./bin/macos-setup shell
./bin/macos-setup config
./bin/macos-setup mise
./bin/macos-setup npm-tools
./bin/macos-setup opencode
./bin/macos-setup nvim
./bin/macos-setup vscode
./bin/macos-setup cursor
./bin/macos-setup zed
./bin/macos-setup yazi
./bin/macos-setup herdr
```

Configuration deployment uses symlinks back into this checkout. An existing
target is moved first to a timestamped directory under
`~/.local/state/dotfiles-macos/backups/`; it is never silently overwritten.

Pi preferences are an exception to symlink deployment: setup merges
`config/pi/settings.json` into the local `~/.pi/agent/settings.json`, preserving
runtime and unknown keys. Existing settings are backed up before changes;
legacy symlinks are detached so Pi cannot write into the checkout. The statusline
extension remains linked. Node must be installed before running the config phase.

The `cx` alias uses the local Codex user configuration. The managed
`config/codex/dotfiles.config.toml` is a reference for manually updating local
settings; setup does not merge it into the user configuration.
`sol` selects `gpt-6.1-sol` at low effort; `luna` selects `gpt-6-luna` at xhigh effort.
`terra` is retained as a compatibility alias for Sol at medium effort.

## Shell

The managed Zsh setup keeps durable configuration under `config/zsh/` with
`ZDOTDIR=~/.config/zsh`. Homebrew's prefix is exported from `~/.zshenv` so
non-interactive tools (editors, launch agents, scripts) see it on PATH;
`integrations.zsh` loads fzf key-bindings/completion from the active
`brew --prefix`. Starship renders the prompt, Atuin keeps history
local-only, and four pinned direct-sourced plugins
(`zsh-autosuggestions`, `fast-syntax-highlighting`, `fzf-tab`, and
`zsh-history-substring-search`) replace any plugin manager. `fzf-tab` renders
the completion menu as an fzf-powered picker. Machine-local overrides belong in
`~/.zshenv.local` and `~/.config/zsh/local.zsh`, both optional and ignored by Git.

## Managed configuration

Beyond the shell, the `config` phase currently links Starship, bat, tmux +
Sesh (with a Vesper status bar and `Ctrl+Space` prefix), Atuin (local-only
history), and Ghostty (Vesper from `config/ghostty/themes/Vesper`,
JetBrainsMono Nerd Font 14, macOS-native window chrome with `Opt` as `Alt`,
Sparkle auto-update off). Tmux copies selections to the macOS
clipboard with `pbcopy`, and `Prefix b` opens the Sesh session picker while
`Prefix Tab` switches to the previous session. The `config` phase also links
`config/opencode/` (opencode.jsonc and tui.jsonc) into `~/.config/opencode/` so the
standalone `opencode` CLI picks up Vesper-aware settings, permission
defaults. Herdr installs and updates its own session-selection plugin; setup
removes legacy repository links to that plugin. It also merges managed Pi
preferences into a local settings file and links a Vesper statusline extension
into `~/.pi/agent/`; the extension
shows project, Git, model, thinking, context, token, cost, tool, message, and
agent-activity state and can be toggled with `/statusline`. It also links a
Codex reference config as `~/.codex/dotfiles.config.toml`. Use it to manually
update `~/.codex/config.toml` when needed; `cx` uses the local user settings.

## Editors

The `nvim` phase links a managed LazyVim configuration with the self-contained
Vesper colorscheme, matching the terminal palette. The `vscode` phase links a
Vesper-themed settings.json and macOS keybindings into
`~/Library/Application Support/Code/User/` and installs the reviewed extension
allowlist (Vim, Remote SSH and its edit and explorer extensions, Remote
Containers, Docker, the containers extension, GitHub Pull Requests, GitHub
Actions, Vesper, and Excalidraw). VS Code's Ghostty integration is preconfigured via
`terminal.external.osxExec`. The `cursor` phase links its own managed settings
and macOS keybindings and maintains an independent extension allowlist. The
`zed` phase links editor-only settings,
macOS-native keybindings, and the same Vesper theme into `~/.config/zed/`;
Zed's accounts, AI/provider settings, extensions, and runtime state stay local.

## macOS defaults

The `macos-defaults` phase applies reviewed System Settings equivalents via
`defaults write`:

- **Keyboard**: fast repeat (`KeyRepeat=2`, `InitialKeyRepeat=15`),
  press-and-hold disabled (Vim-style), all automatic text substitutions off
  (spelling, capitalization, period, quotes, dashes).
- **Finder**: show hidden files and all extensions, path bar + status bar,
  list view default, search current folder, no extension-change warning,
  Finder animations off, window title left at the default name (the POSIX-path
  title is written off), no `.DS_Store` on network volumes, and hide
  external/removable/internal/network volume icons on the Desktop (files
  and folders on the Desktop remain visible).
  (Optional, currently unset: `defaults write com.apple.finder QuitMenuItem -bool true`
  would let `Cmd+Q` quit Finder — including hiding desktop icons — until
  it's relaunched.)
- **Dock**: 64px tiles, autohide with no delay and no slide animation
  (snap instant), no recent apps, no Spaces reordering, minimize into the app
  icon with the scale effect, and no launch animation.
- **Trackpad**: tap-to-click, three-finger drag, and a slightly faster scroll
  speed. Mouse pointer acceleration is intentionally left at the OS default.
- **Screenshots**: save PNG without shadow or thumbnail preview to
  `$XDG_DATA_HOME/pictures/screenshots` (default `~/.local/share/pictures/screenshots`, created if missing, honors `XDG_SCREENSHOTS_DIR` when set).
- **Menu bar**: clock shows date and weekday; battery shows percentage.
- **General UI**: always dark mode, reduced motion, merged titlebar/toolbar,
  expanded save/print panels, new documents save locally instead of iCloud.

Finder, Dock, and SystemUIServer are restarted at the end to take effect
without logout. Risky settings (quarantine, Siri, Spotlight, Touch ID,
Software Update) are intentionally not managed.

## Chrome

The `chrome-defaults` phase mirrors Fedora's Chromium policies at the user
level (no sudo, applies to the current account only):

- `DefaultBrowserSettingEnabled = false` — suppress the default-browser
  prompt.
- `DefaultNotificationsSetting = 2` — block all site notifications.
- `PasswordManagerEnabled = false` — rely on 1Password instead of Chrome's
  built-in password manager.

Chrome must be restarted for these to take effect.

## OpenCode

The `opencode` phase uses the official v2 installer with `--no-modify-path`.
The managed `config/zsh/zshenv` adds `~/.opencode/bin` to PATH. Setup checks
that the standalone binary runs before removing the legacy `opencode-ai`
package from Mise-managed Node. Repeated setup skips an installed binary.
OpenCode settings and sessions are preserved. Use `opencode upgrade` for updates.

To recover the legacy installation, run
`mise exec node@latest -- npm install -g opencode-ai` and move the standalone
`~/.opencode/bin/opencode` aside so the npm binary is selected.

## Development runtimes

The `mise` phase installs Node.js globally (`node@latest`). The `npm-tools`
phase installs the global npm allowlist: `pnpm`,
`@openai/codex`, `@earendil-works/pi-coding-agent`, and
`@devcontainers/cli`. Python tooling comes from `uv` (installed via Homebrew);
`uv` and `uvx` Zsh completions are sourced from `integrations.zsh`. The `ollama`
phase starts the Homebrew login service. The `herdr` phase downloads the
official installer to a temp file, prints its
SHA-256, asks for terminal confirmation before running it (no silent
curl-bash), and links the managed herdr config with the Vesper theme,
`prefix+shift+o`/`prefix+shift+u` worktree bindings, "spaces" agent panel,
dot status indicators, no sound, and `onboarding=false`. `macos-update` sets
`DOTFILES_MACOS_ASSUME_YES=1`, which skips that confirmation.

`macos-update` upgrades all installed Homebrew packages and explicitly installs
the latest versions of installed managed npm tools through Mise-managed Node.
Pi retains `--ignore-scripts`; other npm tools keep their required install scripts.
Unmanaged npm packages are untouched.

## Yazi


The `yazi` phase links the managed configuration at `config/yazi/` —
`yazi.toml`, `keymap.toml`, `theme.toml`, `package.toml`, and the
self-contained Vesper flavor at `flavors/vesper.yazi/` — into
`~/.config/yazi/`. The Vesper flavor covers manager, tabs, mode, status,
pick, input, cmp, tasks, which, help, spot, notify, filetype, and icon
sections using the palette shared with Ghostty, Zed, and Neovim. The `y`
shell wrapper (in `config/zsh/aliases.zsh`) changes the shell's working
directory on Yazi exit (press `q` to accept, `Q` to stay).

## Scope

Setup milestones are planned in
[GitHub Issues](https://github.com/bharatsuri1/dotfiles-macos/issues) and are
added one approved component at a time. The legacy macOS setup at
https://github.com/bharatsuri1/dotfiles is reference only and not a source of
truth.

Authentication, shell history, SSH keys, application credentials, caches, and
generated runtime files must stay outside Git.
