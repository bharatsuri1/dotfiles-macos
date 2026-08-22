# Repository Guidelines

## Project Structure & Module Organization

This repository provides an idempotent macOS laptop setup CLI. `bootstrap.sh` bootstraps the checkout. `bin/macos-setup` dispatches setup phases in `lib/macos-setup/*.sh`; shared helpers and constants belong in `common.sh`. Managed settings live under `config/`, static images in `assets/`, and plans in `docs/`.

When adding a phase, define an `install_<name>` function in a focused module, source it from `bin/macos-setup`, add its command to `usage()` and `main()`, and place it correctly in the `apply` dependency order.

## Build, Test, and Development Commands

There is no build step. Validate changes from the repository root:

- `./bin/macos-setup --help` checks CLI loading and command documentation.
- `./bin/macos-setup status` reports current managed state.
- `./bin/macos-setup --dry-run apply` previews setup without mutation (macOS required). There is no global `--yes` bypass: state-changing commands use each tool's own non-interactive flags (for example `brew upgrade` does not prompt) or a terminal confirmation prompt via `confirm`.
- `shellcheck bootstrap.sh bin/macos-setup lib/macos-setup/*.sh` performs static Bash analysis when ShellCheck is installed.
- `bash -n bootstrap.sh bin/macos-setup lib/macos-setup/*.sh` checks shell syntax.

Run a focused dry-run command, such as `./bin/macos-setup --dry-run homebrew`, for the phase you changed.

## Work Tracking

Use [GitHub Issues](https://github.com/bharatsuri1/dotfiles-macos/issues) as the authoritative repository tracker; do not maintain a parallel backlog in repository files or leave deferred work only in code comments. Use the `gh issue` CLI to list, view, create, update, and close tickets. Before starting tracked work, review the relevant open issue and keep its scope and acceptance criteria current.

Create issues with an outcome-oriented title and actionable checkboxes. Record dependencies, validation, and rollback work when relevant. Put lengthy designs in `docs/` and link them from the issue. Link implementation work to its issue, and close the issue only after recording the completed outcome and validation.

## Coding Style & Naming Conventions

Use Bash with `#!/usr/bin/env bash` and `set -Eeuo pipefail`. Indent with two spaces. Name functions and local variables in `snake_case`; use `UPPER_SNAKE_CASE` for readonly globals. Prefer arrays for command arguments and quote every expansion. Route state-changing commands through the shared `run` helper so dry-run mode remains accurate. Keep operations idempotent: detect completed work, log it, and avoid silently overwriting user configuration.

## Testing Guidelines

No automated test framework or coverage threshold is currently configured. At minimum, run `bash -n`, ShellCheck, and relevant dry-run/status commands. Changes involving sudo, login services, login items, or `defaults` domains should be manually verified on macOS and include recovery considerations.

## Commit & Pull Request Guidelines

Use short, imperative subjects such as `Add managed Ghostty configuration`. Keep commits focused and explain non-obvious safety decisions in the body. Pull requests should summarize changes, list validation, identify affected macOS versions, and include screenshots for visible changes. Never commit secrets, history, browser profiles, caches, or runtime state.
