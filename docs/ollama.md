# Ollama

Managed as the CLI formula `brew "ollama"` (Brewfile, Batch 4). The server is
run on demand (`ollama serve`) or as a login service (`brew services start
ollama`).

## Why not the official installer

The app installer (`curl -fsSL https://ollama.com/install.sh | sh`) and the
`ollama-app` cask install the GUI app (`Ollama.app`) with a menu bar server.
The install script was reviewed and rejected for this repo:

- No checksum or signature verification of the downloaded zip (TLS-only trust).
- Not idempotent: it always re-downloads (~300MB) and reinstalls the app.
- May require interactive `sudo` for the `/usr/local/bin/ollama` symlink.
- Side effects (kills and relaunches the app, starts the server) that cannot
  be represented accurately in dry-run mode.

## Uninstall (brew formula, the managed path)

```
brew services stop ollama  # no-op if the service was never started
brew uninstall ollama     # also remove the Brewfile line
brew autoremove           # drops mpdecimal/python@3.14/mlx/mlx-c if orphaned
rm -rf ~/.ollama          # optional: models (usually the largest directory)
```

Then remove the `brew "ollama"` line from the Brewfile and the parity row in
`docs/ownership-and-parity.md`.

## Uninstall (app install)

If Ollama was ever installed via the install script or the `ollama-app` cask
(official steps from https://docs.ollama.com/macos#uninstall, corrected):

```
sudo rm -rf /Applications/Ollama.app
sudo rm -f /usr/local/bin/ollama
rm -rf "$HOME/Library/Application Support/Ollama"
rm -rf "$HOME/Library/Saved Application State/com.electron.ollama.savedState"
rm -rf "$HOME/Library/Caches/com.electron.ollama"
rm -rf "$HOME/Library/Caches/ollama"
rm -rf "$HOME/Library/WebKit/com.electron.ollama"
rm -rf ~/.ollama
```

Notes:

- `sudo` is only needed for the first two system paths; everything under
  `~/Library` is user-owned.
- The official docs quote `"~/Library/..."`, which does not expand `~` and
  silently no-ops; use `$HOME` inside quotes instead.
- `~/.ollama` holds downloaded models and is usually the largest consumer of
  disk space; remove it only if you do not plan to reinstall.
- For the `ollama-app` cask, `brew uninstall --zap --cask ollama-app` covers
  the `~/Library` paths above (except `~/Library/Caches/ollama` and the
  `/usr/local/bin` symlink, which the cask never creates).
