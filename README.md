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

## Scope

Setup milestones are planned in
[GitHub Issues](https://github.com/bharatsuri1/dotfiles-macos/issues) and are
added one approved component at a time. The legacy macOS setup at
https://github.com/bharatsuri1/dotfiles is reference only and not a source of
truth.

Authentication, shell history, SSH keys, application credentials, caches, and
generated runtime files must stay outside Git.
