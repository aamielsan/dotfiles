---
name: marie-kondo
description: Declutter my setup (dotfiles, Neovim config, tool leftovers) with evidence, keeping only what earns its place.
disable-model-invocation: true
---

# Marie Kondo

A declutter pass over the owner's setup: the mise dotfiles repo (`~/.config/mise`), the Neovim config repo (`~/.config/nvim`), and what the tools leave on disk. Every item either **earns its place**, backed by evidence, or becomes a candidate to let go. The owner says yes before anything goes.

First read `~/.config/mise/CLAUDE.md` and `README.md`. Their principles (simplicity, ownership, measure) decide what earns its place; their rules govern validation and commits.

## 1. Take stock

Derive every list from the config files (`config.toml`, `config.work.toml`, `home/`, `~/.config/nvim/lua/`). Done when every item in every category has a line: its evidence of use, or why there is none.

| Category | Evidence |
|---|---|
| GUI apps (`[bootstrap.packages]`) | `mdls -raw -name kMDItemLastUsedDate /Applications/<app>.app` |
| mise tools (`[tools]`) | last access of the newest binary under `~/.local/share/mise/installs/<tool>/` (`stat -f %a`); `mise prune --dry-run` for versions nothing uses |
| Aliases and shell functions | use in `~/.zsh_history`; check its first timestamp, since a short history proves little |
| Config lines | each against the tool's no-config default (see Reference): restated defaults and dead settings are candidates |
| Neovim plugins, servers, parsers | plugin dirs vs `lazy-lock.json`; Mason packages vs configured servers and tools; parsers vs the install list; projects on disk that need them (`find ~/workspace -name <marker>`) |
| Tool leftovers | Zim modules on disk vs `.zimrc`; anything a removed setting left behind |
| Personal files the config points at | e.g. `~/.aws/config.*` vs the aliases that use them: orphans and old backups |
| Growing caches | e.g. `~/.cache/nvim/kotlin-lsp/` |
| Agent leftovers | sandboxes and test repos earlier agent sessions left in `/tmp` |

## 2. Report

Three groups, one line per item with its evidence:

- **Earns its place**: kept, and why.
- **Could go**: the candidate, its evidence, and what removing it costs.
- **Your call**: what only the owner can judge, e.g. Neovim config shared with another machine that may use what this one doesn't.

Then wait for the owner's choices.

## 3. Let go

For each approved item:

1. Remove it with the tool's own command (see Reference), so the tool's state stays consistent.
2. Prove nothing else changed: shell state and startup time, Neovim's effective state, and the sandbox dry-run with and without `-E work` from `CLAUDE.md`.
3. Update the README wherever it described the item.

Done when every approved item is gone and verified. Commit as `CLAUDE.md` says: one concern per commit, diff shown first.

## Reference

**No-config defaults**
- Neovim: `nvim --clean --headless -c 'lua io.stdout:write(vim.inspect(vim.o.<option>))' -c 'qa!'`; for terminal-dependent options (true colour) measure inside tmux after startup.
- tmux: `tmux -L kondo -f /dev/null start-server \; show -g <option> \; kill-server`. A setting is also dead when nothing reaches it any more (check `tmux list-keys`).
- Ghostty: `/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config --default`.
- gopls: `gopls api-json` lists every option and analyzer with its default.
- zsh: compare shell state with and without the line, captured after running `$precmd_functions`: Zim's input module binds keys only at the first prompt.

**Removal commands**
- Zim module: `zimfw uninstall`. It asks y/N on a TTY, so run it in a throwaway tmux server (`tmux -L kondo new-session -d "zsh -lic 'zimfw uninstall; sleep 3'"`, then `tmux -L kondo send-keys y Enter`).
- Neovim plugin: drop its spec, then `nvim --headless "+Lazy! clean" +qa`, which also updates `lazy-lock.json`.
- Mason package: `require("mason-registry").get_package(name):uninstall()` in headless Neovim, waiting until `is_installed()` is false.
- Tree-sitter parser: `require("nvim-treesitter").uninstall(lang):wait(60000)`.
- mise versions: `mise prune`; it keeps a version a running process still uses.
- Files: list them, then `rm` with explicit paths. Personal files need the owner's yes even when orphaned.

**Gotchas**
- Headless Neovim with a live terminal never quits: run it in the background with a kill timer.
- Evidence counts as use only when it reflects the owner, not an agent: the agent's own test runs update atimes too.
