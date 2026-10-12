# CLAUDE.md

This repo is the user's global mise config (`~/.config/mise`), applied with `mise bootstrap`. README.md explains the layout and workflows; read it first.

## Principles

The user maintains this without AI help, so every change is judged on three things, in order:

1. **Speed.** Shell startup, per-prompt latency, and Neovim startup matter most. The user splits tmux panes constantly. Measure before and after (`zsh -i -c exit`, zprof, `EPOCHREALTIME` around precmd functions).
2. **Simplicity.** Prefer native, declarative mise sections (`[dotfiles]`, `[bootstrap.directories]`, `[bootstrap.macos.*]`) and standard config keys over `[tasks]`, scripts, or shell glue. Removing beats adding.
3. **Ownership.** Commit only settings the user deliberately chose. Config that a tool writes or owns stays with that tool:
   - raicode's cert setup in `~/.zshenv`, which is unmanaged on purpose
   - Docker's `config.json`
   - Claude Code, which raicode installs
   - tool defaults: leave them unset rather than restating them

   When a setting seems necessary, prove it (reproduce the failure) before adding it, and give it a one-line comment saying why.

## Changing things

- **Validate in a sandbox, never on the live machine.** Copy the repo to `/tmp/sbx/home/.config/mise`, export `HOME=/tmp/sbx/home` plus `MISE_CONFIG_DIR`, `MISE_DATA_DIR`, `MISE_STATE_DIR` and `MISE_CACHE_DIR` under `/tmp/sbx`, then run `mise [-E work] bootstrap --dry-run`. Applying `mise bootstrap` for real is the user's call.
- **Lockfiles are generated.** Regenerate them with `mise lock --global` and `mise -E work lock --global`; existing lockfiles keep their `macos-arm64`-only platform list.
- **Work-only content goes in `config.work.toml`** and hooks into shared files through optional includes: `~/.aliases.work`, `~/.gitconfig.work`, `~/.ssh/config.d/work`. The shared config must work on a personal Mac where none of those exist.
- **Dotfiles are linked before tools are installed,** so a `[dotfiles]` source can't live inside a mise install directory. The buildx `post-tools` hook exists for that reason. Always dry-run from a fresh clone with no tools installed in the sandbox.
- **mise can't edit a file that's also a symlinked dotfile.** That's why SSH uses `Include ~/.ssh/config.d/*`, and why `.zshrc` calls `mise activate` itself rather than using `[bootstrap.mise_shell_activate]`.
- **Ordering in `.zshrc` matters.** `mise activate` must run before Zim's init, because Zim's fzf module checks for fzf at load. zoxide init stays last.
- **The Neovim config is a separate repo** (`aamielsan/nvim`, cloned to `~/.config/nvim`). Mason owns language servers and formatters; this repo only provides runtimes and CLIs. Keep the user's existing keymaps when changing plugins.
