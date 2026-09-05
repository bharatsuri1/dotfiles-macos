# Zed

The managed macOS Zed setup installs the stable Homebrew cask and links
editor-only configuration. Zed AI/provider preferences, accounts, extensions,
workspace data, logs, caches, and databases remain local.

## Ownership

| Object | Owner | Path |
| --- | --- | --- |
| Settings | This repository | `~/.config/zed/settings.json` |
| Vesper theme | This repository | `~/.config/zed/themes/vesper.json` |
| Keymap | This repository | `~/.config/zed/keymap.json` |
| AI/provider settings, accounts, extensions, runtime state | User / Zed | Not managed |

The settings enable the Vesper theme, Vim mode, relative line numbers,
JetBrainsMono Nerd Font, editor ergonomics, telemetry opt-out, and the
editor-only preferences shared with Fedora. The macOS keymap retains the shared
Vim/leader workflow while using `cmd-` shortcuts for copy, paste, save, find,
undo, redo, and related editing actions.

## Commands

| Command | Effect |
| --- | --- |
| `./bin/macos-setup homebrew` | Installs the Zed cask with the managed Brewfile |
| `./bin/macos-setup zed` | Backs up conflicts and links settings, theme, and keymap |
| `./bin/macos-setup status` | Reports app and symlink state |
| `./bin/macos-setup --dry-run zed` | Previews the phase without mutation |

The phase requires Zed to be installed outside dry-run mode. If the `zed`
terminal command is wanted, install it from Zed's command palette using
`cli: install cli binary`; this repository does not write to `/usr/local/bin`.

## Validation and rollback

```bash
python3 -m json.tool config/zed/settings.json >/dev/null
python3 -m json.tool config/zed/themes/vesper.json >/dev/null
python3 -m json.tool config/zed/keymap.json >/dev/null
bash -n bin/macos-setup lib/macos-setup/zed.sh
./bin/macos-setup --dry-run zed
```

To stop managing the files, remove the three links under `~/.config/zed/`.
Any displaced files are retained under
`~/.local/state/dotfiles-macos/backups/`. Removing Zed itself is deliberately
separate: `brew uninstall --cask zed`.
