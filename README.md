# dotfiles

My macOS setup as a single [mise](https://mise.jdx.dev) config. This repo **is**
`~/.config/mise`: `mise bootstrap` reads it and installs tools and apps, links
dotfiles, clones my Neovim config, applies macOS settings and loads background
jobs. No Homebrew install (apps come from Homebrew's cask catalogue through
mise) and no install scripts.

The config is the source of truth: `config.toml`, `config.work.toml` and the
files in `home/`. This README describes what they set up; if the two ever
disagree, the config wins and this file gets fixed.

## New machine

1. Install the Xcode Command Line Tools (git, C compiler):
   ```sh
   xcode-select --install
   ```
2. Install mise:
   ```sh
   curl https://mise.run | sh
   ```
3. Clone this repo into `~/.config/mise` and apply it. This is the work laptop
   command; on a personal Mac, drop `-E work` (see [Modules](#modules)):
   ```sh
   ~/.local/bin/mise -E work bootstrap --adopt aamielsan/dotfiles
   ```
   It asks for your password once (app installs need sudo). If it stops because
   a dotfile already exists as a real file, move that file away and run it again.
4. Work laptop only: remember the module for this machine, so plain
   `mise bootstrap` keeps applying it:
   ```sh
   echo 'env = ["work"]' > ~/.config/mise/miserc.local.toml
   ```
5. Log out and back in (for the trackpad settings), open Ghostty, then do the
   [manual steps](#manual-steps).

## Manual steps

- Caps Lock and Escape (hold for Ctrl, tap for Esc): open Karabiner-Elements,
  then in System Settings turn on its driver (General → Login Items &
  Extensions → Driver Extensions) and allow Karabiner-Core-Service under
  Privacy & Security → Input Monitoring. Until the driver is on, both keys work
  as normal. Then in Karabiner: Complex Modifications → Add predefined rule →
  enable "Change caps_lock to control…" and "Change escape to control…".
- SSH keys: put `github-personal` (and `github-dnb` and `gitlab-dnb` at work) in
  `~/.ssh/` and add each `.pub` to its account. Check with `ssh -T git@github.com` and
  `ssh -T dnb@dnb.ghe.com` (the DNB host's SSH user is `dnb`, not `git`).
- Claude Code status in tmux: `workmux setup --hooks` adds the hooks that show
  🤖/💬/✅ next to a window's name.
- IntelliJ: turn on Settings → Backup and Sync with your JetBrains account; it
  restores settings and plugins (IdeaVim) on a new machine. Point the project
  SDK at `~/.local/share/mise/installs/java/corretto-25`.
- Work laptop:
  - run `raicode` to sign in, then `raicode manage fix-certs` and open a new
    terminal;
  - copy the `~/.aws/config.<set>` files from the old machine;
  - log the GitHub CLI in to DNB's GitHub, which the fork sync uses:
    `gh auth login --hostname dnb.ghe.com`;
  - in server-side, `gh repo set-default dnb.ghe.com/pm-server-side/server-side`
    so `gh pr …` commands look at upstream's pull requests.

## Day to day

| I want to… | Do this |
|---|---|
| Re-apply everything after editing | `mise bootstrap` (`--dry-run` first to preview) |
| See what applying would change | `mise bootstrap plan` (`mise bootstrap status` lists every part's state) |
| Add a CLI tool | `mise use -g <tool>` (writes to `config.toml`), commit |
| Update tools | `mise upgrade`, then `mise bootstrap` (repoints the Docker buildx and compose plugins), commit `mise.lock` / `mise.work.lock` |
| Add a dotfile | put it in `home/`, add a line under `[dotfiles]`, `mise dotfiles apply` (links dotfiles only) |
| Edit a dotfile | edit it in place (`~/.zshrc` etc. are symlinks into `home/`) |
| Add a GUI app | add `"brew-cask:<name>" = { adopt = true }` under `[bootstrap.packages]` ([find names](https://formulae.brew.sh/cask/)), `mise bootstrap`, commit |

GUI apps update themselves; mise only installs them.

## What's set up

### Shell

zsh with [Zim](https://zimfw.sh): modules are listed in `home/.zimrc`, and Zim
installs itself on the first shell start. `.zprofile` sets the environment and
PATH (mise shims), `.zshrc` does the interactive setup (full `mise activate`).

- **Vi keys:** Esc for normal mode. While typing, Up/Down and Ctrl-P/Ctrl-N
  search history for what's typed so far; in normal mode, `k`/`j` do the same.
- **fzf:** Ctrl-R history, Ctrl-T files, Option-C cd, `**<Tab>` completion.
- **zoxide:** `z <dir>` jumps to a folder you've visited, `zi` picks one
  interactively. It knows about worktrees; see [Worktrees](#worktrees).
- **Git aliases** come from Zim's git module with a lowercase prefix (`gf`
  fetch, `gr` rebase, `gb` branch, `gW…` worktrees, …); `gh` stays the GitHub CLI.
- **Prompt** is Zim's asciiship, with suggestions from history as you type and
  syntax highlighting.

### Terminal

Ghostty opens fullscreen straight into the tmux session `main`, so sessions
outlive the window. The theme is Rose Pine and follows macOS light/dark mode.
The tmux prefix is `C-a`:

| Key | Does |
|---|---|
| `C-a \` / `C-a -` | Split side by side / stacked, in the pane's folder |
| `C-a h` `j` `k` `l` | Move between panes |
| `C-a q` | Close the pane |
| `C-a t` | Name the pane |
| `C-a c` | New window (asks for a name) |
| `Ctrl-Tab` / `Ctrl-Shift-Tab` | Next / previous window |
| `C-a [` | Copy mode (vi keys): select with `v`, copy to the system clipboard with `y` |
| `C-a v` | Open the pane's scrollback in Neovim |
| `C-a C-k` | Clear the screen and scrollback |
| `C-a C-q` | Close every other session |

The status bar sits at the top and highlights the current window; the session
name flips colour after you press the prefix. A window where Claude Code runs
(on its own or inside Neovim) shows its state after the name: 🤖 working, 💬
waiting for you, ✅ done; the last two clear when you switch to it. The mouse
works too.
`Ctrl-Tab` and `Ctrl-Shift-Tab` are Ghostty keybinds that send `C-a n` and
`C-a p`, so change them too if you ever change the prefix.

### Worktrees

Repos go in `~/workspace/personal/` (every machine) or `~/workspace/dnb/`
(work; uses the work git identity), one folder per repo. To work on several
branches of one repo at once, use git worktrees through
[workmux](https://github.com/raine/workmux) (alias `wm`): each worktree lives in
`<repo>__worktrees/<name>` and gets its own tmux window with one shell.

| Command | Does |
|---|---|
| `wma <branch>` | Worktree and window for an existing branch; `origin/<branch>` for one that's only on the remote |
| `wma <new-branch> --base upstream/master` | Same for a new branch, starting from upstream |
| `wml` | List worktrees |
| `wmc <name>` / `wmo <name>` | Close the window, keeping the worktree / reopen it |
| `wmx <name>` | Remove worktree, window and branch; refuses with uncommitted changes, asks before deleting an unmerged branch |
| `wmpr <n>` (work) | Open pull request `<n>` for review, on branch `pr-<n>` |
| `wmpru` (work) | Inside a `wmpr` worktree: catch up with the PR, force-pushes included; your own commits and edits are kept |

`<name>` is the worktree's folder and window name: the branch with `/` turned
into `-` (`ai/feat/x` becomes `ai-feat-x`), or what you passed to `wma` with
`--name <short>`. `wma --dry-run` shows what it would do. Spell the branch
exactly: a name that doesn't exist creates a new branch from whatever is checked
out. A branch can be checked out in only one place at a time. Closing a window
(or its last pane) keeps the worktree; after a reboot, `workmux resurrect`
reopens the worktree windows.

All checkouts of a repo share one zoxide history, so `z`/`zi` open folders in
the checkout you're in, even a brand-new worktree; switch checkouts with tmux
windows. Each worktree gets its own Kotlin LSP indexes (see
[Files other tools write](#files-other-tools-write)).

### Git and SSH

- **Identity:** personal by default; the work email for repos under
  `~/workspace/dnb/`.
- **Behaviour** (`home/.gitconfig`): new repos start on `main`, `pull` rebases
  and stashes uncommitted changes around it, the first `push` sets the
  upstream, `fetch` drops deleted remote branches, diffs use the histogram
  algorithm, conflicts show the original code (zdiff3) and recorded resolutions
  are reused, `git branch` lists the newest first.
- **github.com:** clone and fetch over HTTPS (works before SSH keys exist), push
  over SSH. DNB's hosts use SSH remotes.
- **Global ignore:** `home/.config/git/ignore`.
- **SSH** (`home/.ssh/config`): one key per host, `~/.ssh/github-personal` for
  github.com, and at work `github-dnb` for dnb.ghe.com and `gitlab-dnb` for
  gitlab.tech.dnb.no. Passphrases live in the macOS Keychain, and only the
  configured key is offered. Hosts that only some machines have go in
  `~/.ssh/config.d/`.

### Editors and AI

- **Neovim:** the config lives in its own repo,
  [aamielsan/nvim](https://github.com/aamielsan/nvim), cloned to
  `~/.config/nvim`. mise provides Neovim, the runtimes and the tree-sitter CLI;
  Mason (inside Neovim) installs language servers and formatters.
- **Kotlin in Neovim:** the language server comes from mise for now, because
  Mason's package can't download it
  ([mason-registry#17323](https://github.com/mason-org/mason-registry/pull/17323)).
  Open Neovim inside the Gradle build you work on; the first open imports it
  (under a minute), later opens take seconds. `:lsp restart` re-imports. It
  doesn't follow Gradle `includeBuild` yet
  ([kotlin-lsp#109](https://github.com/Kotlin/kotlin-lsp/issues/109)), so use
  IntelliJ for code in included builds such as `common-kotlin`.
- **IntelliJ:** IdeaVim's `home/.ideavimrc` mirrors the Neovim keymaps that
  have an IntelliJ equivalent.
- **Claude Code:** installed by mise. At work, launch it through `raicode`,
  DNB's wrapper that signs in to the company AI gateway (it can only install
  Claude Code with Homebrew, hence mise).

### Keyboard

Caps Lock and Escape are Ctrl when held and Esc when tapped (Karabiner-Elements;
the rules are in `home/.config/karabiner/`). Vim keys everywhere: zsh, tmux copy mode, Neovim,
and IntelliJ through IdeaVim.

### Containers

Colima runs the Docker engine in a VM; it isn't started automatically. Start it
the first time with `colima start --ssh-config=false` (see
[the catches](#files-other-tools-write)); after that `colima start` remembers
it. amd64 images run under emulation; `colima start --vz-rosetta` (after
`colima stop`) makes that faster. `docker buildx` and `docker compose` work as
plugins: the bootstrap hook links them into `~/.docker/cli-plugins/`.

### Apps, tools and macOS settings

- **Apps:** listed under `[bootstrap.packages]` in `config.toml`, including
  Karabiner-Elements (Caps Lock) and tldraw offline, a local whiteboard whose
  Develop → Install Agent Skills lets Claude Code draw on open canvases. An app
  that's already installed is kept (`adopt = true`), so macOS keeps its
  permissions.
- **Tools:** runtimes, CLIs and the container stack are listed under `[tools]`
  in `config.toml`, with exact versions in `mise.lock`.
- **macOS:** Finder shows hidden files, the trackpad has tap to click and
  two-finger right click, and screenshots are saved as PNG in
  `~/Desktop/Screenshots`.

### Work module

`config.work.toml` adds, on top of everything above:

- the AWS CLI and CDK, and `~/workspace/dnb/`;
- `home/.aliases.work`: AWS account sets (`bankingconf`, `nmbconf`, … point the
  shell's AWS CLI at `~/.aws/config.<set>`, and the prompt shows the set on the
  right, e.g. `aws:banking`; then `awsso` signs in with that set's `sit`
  profile), `wmpr`/`wmpru`, and Go helpers (`goreport`, `buildgo`);
- the work git identity and SSH hosts;
- a LaunchAgent that keeps your fork of the server-side monorepo in sync with
  upstream: at login and hourly, `gh repo sync` asks GitHub to bring the fork's
  `master` up to upstream's. That's a fast-forward as long as nothing is
  committed to the fork's `master`; if something is, GitHub merges upstream in
  instead, and a conflict makes the run fail. Check it with
  `launchctl print gui/$(id -u)/dev.mise.sync-server-side-fork`.

`wmpr` expects the repo's `upstream` remote to be the main repository (in
server-side, `pm-server-side/server-side`), and the fork sync expects your fork
to be called `server-side`.

## Layout

| Path | What |
|---|---|
| `config.toml` | Shared setup for every machine: tools, apps, dotfiles, macOS settings |
| `config.work.toml` | The `work` module (see [Work module](#work-module)) |
| `home/` | Dotfile sources, mirroring `$HOME` |
| `mise.lock`, `mise.work.lock`, `locks/` | Exact tool versions and checksums. Generated by mise; commit them |
| `miserc.local.toml` | Per-machine module choice. Not committed |
| `CLAUDE.md` | Rules for AI agents changing this repo |

## Modules

A module is a `config.<name>.toml` file that only applies on machines that
choose it; mise calls these config environments (`-E`, `env`), and the config's
comments say env. Currently there's one, `work`. A machine picks modules in
`~/.config/mise/miserc.local.toml` (step 4 of [New machine](#new-machine)).

To add one (e.g. `personal`), create `config.personal.toml` and list it there.
To remove a module from a machine: drop it from `env`, then
`mise bootstrap unapply <name>` (preview with `--dry-run`). It removes what the
module's bootstrap sections created; installed tools and apps stay.

Things that only some machines have hook in through files that may or may not
exist: `.zshrc` sources `~/.aliases.work` if present, `.gitconfig` includes
`~/.gitconfig.work` for repos under `~/workspace/dnb/`, and `~/.ssh/config`
includes everything in `~/.ssh/config.d/`.

## Files other tools write

These live outside the repo on purpose. Each tool creates and owns its own:

| Path | Written by |
|---|---|
| `~/.zshenv`, `~/.raicode/` | `raicode manage fix-certs` (Zscaler certificate, work laptop only) |
| `~/.aws/config.<set>` | Me: one AWS config per account set, with account IDs, so not in this repo (work laptop only) |
| `~/.colima/` | Colima: the VM and its settings |
| `~/.docker/config.json` | Docker: registry credentials |
| `~/.zim/` | Zim: modules, downloaded on first shell start |
| `~/Library/Application Support/zoxide/` | zoxide: the folder history (starts empty on a new machine) |
| `~/.config/gh/hosts.yml` (token in the Keychain) | GitHub CLI: logins from `gh auth login` |
| `~/.local/state/workmux/` | workmux: log and state |
| The `Notification`, `PostToolUse`, `SessionStart`, `Stop` and `UserPromptSubmit` hooks in `~/.claude/settings.json` | `workmux setup --hooks`: Claude Code's state shown in tmux window names |
| `~/.local/share/nvim/` | Neovim: plugins, Mason servers, Tree-sitter parsers |
| `~/.cache/nvim/kotlin-lsp/` | Kotlin LSP: about 2 GB of indexes per Gradle build opened, in each checkout, under `workspaces/`, plus logs under `system/log/`. Nothing removes them; delete `workspaces/` now and then (safe) |
| `~/.local/share/mise/`, `~/.local/state/mise/` | mise: installed tools and bootstrap state |
| `~/Library/LaunchAgents/dev.mise.*.plist` | mise bootstrap, from the LaunchAgents in the config |
| `~/.config/karabiner/karabiner.json` | Karabiner: which rules are enabled |
| `~/Library/Application Support/JetBrains/` | IntelliJ: settings, plugins (IdeaVim), memory |
| `~/Library/Application Support/tldraw/` | tldraw offline: app data, and, while it runs, `server.json` with the local agent API's port and token |
| `~/skills/tldraw-offline/`, `~/.claude/skills/tldraw-offline/`, `~/.claude/agents/tldraw-offline.md`, the `SubagentStart` hook in `~/.claude/settings.json` | tldraw offline's Develop → Install Agent Skills (remove with Develop → Uninstall Agent Skills) |

Two catches:

- Colima writes an `Include` into `~/.ssh/config`, which is a file in this
  repo. Start it the first time with `colima start --ssh-config=false`; it
  remembers the setting.
- `fix-certs` only adds its line to `~/.zshenv`
  (`[ -f ~/.raicode/env.sh ] && . ~/.raicode/env.sh`) on its first run. If that
  line goes missing, move `~/.raicode/env.sh` away and run `fix-certs` again.
