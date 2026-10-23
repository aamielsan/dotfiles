# CLAUDE.md

This repo is the user's global mise config (`~/.config/mise`), applied with `mise bootstrap`. The config (`config.toml`, `config.work.toml`, `home/`) is the source of truth; README.md describes it (layout, modules, workflows, the files other tools own). Read README.md before changing structure, and update it in the same change whenever the config changes what it describes.

## Principles

The user maintains this without AI help, so every change is judged on three things, in order:

1. **Simplicity.** A simple, straightforward setup beats a faster one. Prefer native, declarative mise sections (`[dotfiles]`, `[bootstrap.directories]`, `[bootstrap.macos.*]`) and standard config keys over `[tasks]`, scripts, or shell glue. Removing beats adding.
2. **Speed, pragmatically.** Shell startup, tmux pane splits, per-prompt latency, and Neovim startup should feel fast, but a few milliseconds never justify extra config or a workaround. Measure before and after, and quote the numbers.
3. **Ownership.** Commit only settings the user deliberately chose. Files a tool writes stay with that tool (README's "Files other tools write"), and tool defaults stay unset rather than restated. Prove a setting is needed (reproduce the failure) before adding it, and give it a one-line comment saying why.

## Working with the user

- Recommend one option, backed by measurements, and say what it costs.
- Show the diff and wait for an OK before every commit. One commit per concern. Push only when asked.
- For interactive behaviour (tmux bindings, keymaps, prompts), apply it live and temporarily first (`tmux source-file` on a scratch file) so the user can try it, then persist it once they confirm.
- Keep the user's username out of the repo; write `~` or `$HOME`.
- Keymaps are vim-style everywhere and the user's existing keys stay. A Neovim keymap change gets mirrored in `home/.ideavimrc`.

## Changing things

- **Validate in a sandbox, never on the live machine.** Clone the repo to `/tmp/sbx/home/.config/mise`, `cd /tmp/sbx/home`, and run `mise [-E work] bootstrap --dry-run` with `HOME=/tmp/sbx/home` and `MISE_CONFIG_DIR`, `MISE_DATA_DIR`, `MISE_STATE_DIR`, `MISE_CACHE_DIR` under `/tmp/sbx`. Run it from inside the sandbox: mise also reads `.config/mise` in every parent of the working directory, so a run under `~` picks up the live config. Dry-run both with and without `-E work`.
- **Applying is mostly the user's call.** `mise dotfiles apply` (preview with `-n`) links dotfiles only and is fine after a clean dry-run; a full `mise bootstrap` is the user's to run. Cask installs that ship a `.pkg` need sudo, which the `!` prefix can't provide, so the user runs those in a terminal.
- **Lockfiles are generated.** Regenerate them with `mise lock --global` and `mise -E work lock --global`; existing lockfiles keep their `macos-arm64`-only platform list.
- **Work-only content goes in `config.work.toml`** and reaches shared files only through the optional includes listed in README's "Modules". The shared config must work on a personal Mac where none of those exist.
- **Dotfiles are linked before tools are installed,** so a `[dotfiles]` source can't live inside a mise install directory. The buildx `post-tools` hook exists for that reason.
- **mise can't edit a file that's also a symlinked dotfile.** That's why SSH uses `Include ~/.ssh/config.d/*`, and why `.zshrc` calls `mise activate` itself rather than using `[bootstrap.mise_shell_activate]`.
- **Ordering in `.zshrc` matters.** `mise activate` runs before Zim's init, because Zim's fzf module checks for fzf at load. zoxide init (`--hook none`) stays last, followed only by the functions that record directories and redefine `z` and `zi`.
- **The Neovim config is a separate repo** (README's "Editors and AI"). Mason owns language servers and formatters; this repo only provides runtimes and CLIs.

## Settled decisions

Each was measured on this machine. Re-open one only with new evidence.

- **git** runs through Apple's `/usr/bin/git` wrapper (~4 ms extra per call; a prompt in a repo makes 7 calls, so ~25 of its ~41 ms). The Command Line Tools `bin` directory stays off `PATH`: it shadows mise's `python3` and puts a `clang` that can't find the SDK headers ahead of Apple's shims. A lone `git` symlink to the Command Line Tools binary doesn't work either: git then looks for its helpers in Xcode, so submodules, templates and the Keychain credential helper break.
- **`core.fsmonitor` stays off.** Its daemon round trip made every prompt slower, even in the 27k-file `server-side` repo. For a slow prompt in one big repo, set `git config zim.hide-dirty true` in that repo.
- **mise:** shims in `.zprofile` for non-interactive login shells, `mise activate` in `.zshrc`. Shims alone add 9–15 ms to every command and drop `JAVA_HOME`; `hook_env.chpwd_only` changed nothing. Skipping the shims in interactive shells saves ~9 ms per shell with identical state; a plain PATH line instead of the eval leaves an extra PATH entry and ignores `MISE_DATA_DIR`.
- **Prompt** is Zim's asciiship. Starship took ~540 ms in `server-side`.
- **tmux** stays, because sessions must outlive the terminal. Panes are login shells; non-login panes measured no gain.
- **Claude Code** stays installed by mise (README's "Editors and AI" says why).

## Testing gotchas

- `zsh -i -c exit` skips the first prompt. To time what the user sees, split a pane in a detached tmux session and poll `tmux capture-pane -p` until the prompt appears; time prompt cost with `EPOCHREALTIME` around `$precmd_functions`.
- Zim sets `noclobber`, so overwrite files from zsh with `>|`.
- Load tmux config through tmux's parser (`tmux source-file`, or a throwaway server: `tmux -L test -f FILE`). Typed in a shell, `\;` splits the line into separate commands that run immediately.
- In tmux 3.7, `list-keys -T TABLE KEY` prints nothing; grep the output of `list-keys -T TABLE`. `display-popup` doesn't expand formats such as `#{pane_id}` in its command, so capture in the binding before opening the popup.
