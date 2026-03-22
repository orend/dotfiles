# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for macOS, expected to be cloned to `~/bin/dotfiles`. Shell config uses bash as the primary shell (zsh is configured to exec into bash).

## Installation

Files are copied (not symlinked) to their destinations:
- `cp .bash_profile ~/.bash_profile` then `source ~/bin/dotfiles/bashrc`
- `cp .gitconfig ~/` and `cp .gitignore ~/`
- `cp ec ~/bin/` and `cp emacs ~/bin/`
- `brew bundle` to install packages from Brewfile

## Shell Config Architecture

**Bash** is the primary shell. `zshrc` immediately execs into bash. The bash entrypoint is `bashrc`, which sources:
- `bash/env` — PATH construction (with dedup), RVM, SDKMAN, editor/history/color settings, kubectl/stern completions
- `bash/config` — PS1 prompt (uses `vcprompt` for git branch), color variables, LESS config, direnv hook, SSH keychain loading
- `bash/aliases` — All shell aliases and functions (git shortcuts, Emacs launchers, file utilities, grep helpers)
- `bash/secret` — Private env vars (gitignored)
- `completions` — Sources completion scripts from `completion_scripts/`

## Key Scripts

- **`ec`** — Emacs launcher script used as `$EDITOR`. Tries emacsclient first, falls back to standalone emacs. Supports `-n` flag for no-wait. Opens directories in dired mode.
- **`vcprompt`** — Binary that shows VCS branch in the shell prompt.
- **`.githelpers`** — Pretty git log formatting functions (`pretty_git_log`, `show_git_head`) used by git aliases `l`, `la`, `hp`.

## Git Aliases (in .gitconfig)

Notable custom aliases: `down` (pull with ff-only, fallback to rebase), `pp` (pull then push), `publish`/`unpublish` (manage remote tracking branches), `ll` (compact log), `rec` (recent branches by date).

## Conventions

- Aliases file is the largest and most actively edited file — changes to shell behavior go in `bash/aliases`
- The `e` function and `ec` script both launch Emacs — `e` always opens a new window via `open -n`, `ec` prefers emacsclient
- `rmf` function moves files to Trash instead of deleting them
- `tai` wrapper suppresses gRPC ALTS warnings; `GRPC_VERBOSITY=ERROR` is also set in env
