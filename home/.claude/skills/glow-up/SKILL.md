---
name: glow-up
description: Find, try and keep a few small, evidence-backed improvements to my workflow, ending with a glow-up card.
disable-model-invocation: true
---

# Glow-up

The partner of `/marie-kondo`: it lets go, this adds. Study how the owner actually works, pitch at most three improvements their own usage points to, try them live, and keep what they like.

First read `~/.config/mise/CLAUDE.md` and `README.md`. Every pitch passes their principles: simplicity first, speed measured, only settings the owner chooses, settled decisions stay settled. Prefer a feature a tool already has over a new tool, and a setting over a script; one new tool per run at most.

## 1. Observe

Gather **friction**: where the owner repeats themselves, waits, or works around something. Done when every source below has been read and each friction has evidence: counts, timings, or the repeated thing itself.

| Source | Look for |
|---|---|
| `~/.zsh_history` (note its first timestamp) | long commands typed often (alias), repeated sequences (function), failing or retyped commands |
| `git reflog` across `~/workspace/*/*` and their worktrees | branch switches, rebases, PR reviews, stashes |
| `zoxide query -ls`, `~/.local/state/workmux/workmux.log` | most-visited places, worktrees created and removed by hand |
| tmux (`list-windows -a`, `list-panes -a -F '#{pane_current_command} #{pane_current_path}'`) | what runs where, windows rebuilt by hand |
| Claude Code (`~/.claude/projects/`: sessions per project, first prompts of recent sessions) | where it's used, recurring requests, waits on permission |
| Timings the owner hits often | prompt, new pane, a frequent command; measure as `CLAUDE.md`'s testing gotchas describe |
| The setup itself | features its tools already offer that are still off |

Then read the dotfiles' git log (`git -C ~/.config/mise log --oneline`): it records what was already tried, kept, or dropped, so each pitch is new.

## 2. Pitch

At most three ideas, ranked by friction removed per unit of cost. For each:

- **Friction**: what the owner does now, with its evidence.
- **Change**: what changes, in which file.
- **Cost**: lines of config, any new tool, milliseconds added.
- **Trial**: how to try it live without committing.

Then wait for the owner's picks.

## 3. Try

For each picked idea:

1. Apply it live and temporarily first, as `CLAUDE.md` describes (a scratch tmux file, an uncommitted edit, a file to `source`), and let the owner use it.
2. Keep or drop it on their verdict. A dropped idea is reverted completely.
3. Persist a keeper: validate (sandbox dry-run with and without `-E work`, shell state, Neovim's effective state), update the README, and commit as `CLAUDE.md` says.

Done when every picked idea is either persisted and verified, or dropped and reverted.

## 4. Glow-up card

Close with:

```
✨ Glow-up
Kept      <idea> (<file>)
Measured  <metric: before → after>
Estimated <keystrokes or minutes saved per week>
Dropped   <idea>: <why>
```

Label estimates as estimates. Keystrokes saved per week = uses per week × (characters before − characters after), with uses per week taken over the evidence window.

## Reference

**Gotchas**
- History is deduplicated (`HIST_IGNORE_ALL_DUPS` keeps only the latest copy of a command), so it shows *what* is typed, not how often. Count frequency from git reflogs, zoxide scores, tool logs, or how many variants of a command appear.
- Ideas the git log shows were dropped stay dropped unless the owner reopens them.
- An agent's own activity this session (test commands, sandbox runs) is evidence of nothing; leave it out of counts.
