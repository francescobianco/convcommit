<div align="center">

<img src=".github/assets/header.svg" alt="convcommit demo" width="720"/>

# convcommit

**Interactive [Conventional Commits](https://www.conventionalcommits.org/) builder for the terminal**

[![License: MIT](https://img.shields.io/badge/license-MIT-a6e3a1?style=flat-square)](LICENSE)
[![Shell: Bash](https://img.shields.io/badge/shell-bash-89b4fa?style=flat-square&logo=gnubash&logoColor=white)](bin/convcommit)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-f9e2af?style=flat-square)](https://www.conventionalcommits.org/)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-zero-a6e3a1?style=flat-square)](#installation)
[![Version](https://img.shields.io/badge/version-0.1.0-cba6f7?style=flat-square)](Manifest.toml)
[![GitHub Stars](https://img.shields.io/github/stars/francescobianco/convcommit?style=flat-square&color=f38ba8)](https://github.com/francescobianco/convcommit/stargazers)

</div>

---

## What is convcommit?

Most teams write commit messages inconsistently — terse, cryptic, or simply missing context. Over time this makes git history hard to read, hard to automate, and hard to trust.

**convcommit** is a single bash file that runs a lightweight interactive menu in your terminal: you press one key to select the commit type, optionally type a scope and a message, and it assembles the correctly formatted string and runs `git commit` for you.

It also exposes a full non-interactive API — direct flags and stdin pipe mode — so it fits equally well in shell scripts, Makefiles, CI pipelines, and AI agent workflows, always producing the same standard output.

---

## What are Conventional Commits?

[Conventional Commits](https://www.conventionalcommits.org/) is a lightweight specification for commit message format:

```
<type>(<scope>): <description>
```

Examples:
```
feat(auth): add OAuth2 login
fix(api): handle null response from upstream
docs: update installation guide
chore(deps): bump lodash to 4.17.21
```

The format enables:
- **Automatic changelogs** — tools like `conventional-changelog` parse types to generate release notes
- **Semantic versioning** — `feat` bumps minor, `fix` bumps patch, `BREAKING CHANGE` bumps major
- **Readable history** — anyone can scan the log and understand *what changed and why*
- **Better tooling** — linters, release bots, and AI agents can all reason about structured messages

convcommit enforces this format at the source: at commit time, in your terminal.

---

## Features

- 🎹 Interactive keyboard menu — pick type, scope, message with a single keypress
- 🚀 Direct flags to bypass the selector — great for scripts and AI agents
- 📦 `--add` flag to stage specific files and commit in a single command
- 🔁 `--all` + `--push` for a full stage-commit-push workflow in one liner
- 🛡️ Pre-flight checks — catches empty trees and stale branches *before* you commit
- 🤖 Pipe / stdin mode — fully scriptable, works in CI and LLM contexts
- ⚙️ `.convcommit` config file — per-project vocabulary, committed and shared with the team
- 🅰️ Forced letter syntax `[X]value` — memorable keybindings in your config
- 🦀 Zero dependencies — single bash file, installs anywhere

---

## Installation

**System-wide** (recommended):
```sh
curl -fsSL https://raw.githubusercontent.com/francescobianco/convcommit/refs/heads/main/bin/convcommit \
  -o /usr/local/bin/convcommit && chmod +x /usr/local/bin/convcommit
```

**Per-project** (committed into the repo, great for teams):
```sh
curl -fsSL https://raw.githubusercontent.com/francescobianco/convcommit/refs/heads/main/bin/convcommit \
  -o bin/convcommit && chmod +x bin/convcommit
```

---

## Usage

### Interactive mode

Run inside a git repo and follow the menu:

```sh
convcommit          # → prints the formatted message only
convcommit -a       # → git add . then commit
convcommit -a -p    # → git add . then commit then push
```

Press the **bracketed letter** `[F]`, `[G]`, ... to select an option.
Press `[.]` to type free text when the `_` entry is available.

---

### Direct flags — recommended for scripts and AI agents

Bypass the interactive selector entirely with explicit flags:

```sh
convcommit --type fix --scope auth --message "fix null pointer"
convcommit -t feat -s api -m "add endpoint" -a -p
```

---

### `--add` flag: stage specific files and commit in one command

**❌ Anti-pattern** (nested command substitution — verbose and fragile):
```sh
msg=$(convcommit --type fix --scope auth --message "fix null pointer") \
  && git commit -m "$msg" \
  && git push
```

**✅ Recommended** — one liner, readable, safe:
```sh
convcommit --add src/auth.sh --type fix --scope auth --message "fix null pointer" --push
```

The `--add` flag is **repeatable** — stage as many files as you need:
```sh
convcommit --add src/auth.sh --add tests/auth_test.sh \
  -t test -s auth -m "add auth unit tests" -p
```

---

### Pipe mode — for CI and LLM/AI agents

When stdin is **not a TTY**, convcommit reads selections line-by-line.
Each line corresponds to a stage: **type → scope → message**.

```sh
# F = feat, empty line = no scope, then the message
printf "F\n\nadd endpoint\n" | convcommit -a -p
```

Use `.` to trigger free-text input mid-pipe:
```sh
printf "G\n.\nfix null pointer in login\n" | convcommit
```

Capture just the formatted message:
```sh
msg=$(printf "G\n\nfix null pointer\n" | convcommit)
# → fix: fix null pointer
```

---

### Options

| Option | Description |
|---|---|
| `-t`, `--type <type>` | Commit type — bypasses the interactive selector |
| `-s`, `--scope <scope>` | Commit scope — bypasses the interactive selector |
| `-m`, `--message <msg>` | Commit message — bypasses the interactive selector |
| `-A`, `--add <file>` | Stage a specific file (repeatable) |
| `-a`, `--all` | Stage all changes (`git add .`) before committing |
| `-p`, `--push` | Push to remote after committing |
| `--reset` | Regenerate `.convcommit` with latest defaults |
| `--no-color` | Disable colored output |
| `-V`, `--version` | Print version and exit |
| `-h`, `--help` | Print help and exit |

---

## Configuration — `.convcommit`

On first run, convcommit auto-creates a `.convcommit` file in the current directory.
Commit this file to share the project's commit vocabulary with your team.

### Format

```
type:<value>      — commit type option
scope:<value>     — commit scope option
message:<value>   — commit message template
```

### Special prefixes

| Prefix | Effect |
|---|---|
| `~<value>` | Default selection (highlighted with ★) |
| `_` | Enables free-text input (press `.` in the menu) |
| `[X]<value>` | Forces letter `X` for this entry, overriding the sequential counter |

### Default letter assignment

```
[B] build    ★[C] chore    [D] docs     [E] deps
[F] feat      [G] fix      [H] ci       [I] init
[J] merge     [K] perf     [L] refactor [M] revert
[N] security  [O] style    [P] test     [W] wip
[.] free text
```

`[B]`, `[D]`, `[W]` are forced to skip `A`, keep `D` for docs, and assign the memorable `W` for wip.
Everything else follows alphabetical order — no chaos, no need to memorise a map.

### Customize scopes for your project

```
scope:~
scope:_
scope:api
scope:auth
scope:ui
scope:db
scope:ci
```

### Regenerate defaults

```sh
convcommit --reset
```

---

## Pre-flight checks

When running interactively (stdout is a TTY), convcommit validates before opening the selector:

| Check | Triggered by |
|---|---|
| Working tree is clean | `-a` or `--add` |
| No remote configured | `-p` / `--push` |
| Branch is behind remote | `-p` / `--push` |

> When stdout is captured (`msg=$(convcommit ...)`) checks are skipped — message-only generation never touches git state.

---

## Use convcommit in your AI agent

If you use an AI coding assistant (Claude Code, Cursor, Copilot, etc.), paste the following prompt into your agent's system instructions or project rules file to teach it to use convcommit for every commit:

```
When committing code changes, always use convcommit instead of git commit directly.
Use the direct flags form: convcommit --add <file> -t <type> -s <scope> -m "<message>" [-p]
Reference: https://github.com/francescobianco/convcommit
```

That's it. The agent will stage files, pick the right type, and produce a well-formed Conventional Commit message — without ever opening the interactive menu.

---

## Developer experience tips

**Full release workflow in one shot:**
```sh
convcommit -a -p
```

**Commit a built binary:**
```sh
convcommit --add bin/mytool -t build -s bin -m "update binary" -p
```

**Reset project vocabulary after upstream changes:**
```sh
convcommit --reset && convcommit -t chore -s config -m "refresh convcommit defaults" -a -p
```

---

## Contributing

We welcome contributions! Feel free to fork the repository, submit pull requests, or open issues for any improvements or bug fixes.

## License

This project is licensed under the **MIT License**.
