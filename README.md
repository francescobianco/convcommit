# convcommit

**convcommit** is a lightweight, zero-dependency CLI tool that helps enforce [Conventional Commits](https://www.conventionalcommits.org/) in your Git workflow. It provides an interactive menu for selecting type, scope, and message — and a full non-interactive API for scripting and AI agents.

## Features

- Interactive commit message builder (keyboard-driven menu)
- Direct flags to bypass the selector — great for scripts and AI agents
- `--add` flag to stage specific files and commit in a single command
- `--all` / `--push` flags for one-liner full workflows
- Pre-flight checks: warns before committing or pushing when the state is invalid
- Pipe/stdin mode for non-interactive (CI, LLM agents) usage
- Configurable via a `.convcommit` file per project (auto-created on first run)
- Forced letter assignment (`[X]value`) and default selection (`~value`) in the config

---

## Installation

**System-wide** (recommended):
```sh
curl -fsSL https://raw.githubusercontent.com/francescobianco/convcommit/refs/heads/main/bin/convcommit \
  -o /usr/local/bin/convcommit && chmod +x /usr/local/bin/convcommit
```

**Per-project** (committed into the repo):
```sh
curl -fsSL https://raw.githubusercontent.com/francescobianco/convcommit/refs/heads/main/bin/convcommit \
  -o bin/convcommit && chmod +x bin/convcommit
```

---

## Usage

### Interactive mode

Run inside a git repo and follow the menu:

```sh
convcommit          # print the message only
convcommit -a       # git add . then commit
convcommit -a -p    # git add . then commit then push
```

Press the bracketed letter `[A]`, `[B]`, ... to select an option.
Press `[.]` to type free text when the `_` entry is available.

---

### Direct flags — the recommended pattern for scripts and AI agents

Bypass the interactive selector entirely:

```sh
convcommit --type fix --scope auth --message "fix null pointer"
convcommit -t feat -s api -m "add endpoint" -a -p
```

---

### `--add` flag: stage specific files and commit in one command

This is the cleanest pattern when you want to commit only selected files.

**Anti-pattern** (nested command substitution — verbose and error-prone):
```sh
msg=$(convcommit --type fix --scope auth --message "fix null pointer") \
  && git commit -m "$msg" \
  && git push
```

**Recommended pattern** (one liner, safe, readable):
```sh
convcommit --add src/auth.sh --type fix --scope auth --message "fix null pointer" --push
```

The `--add` flag is repeatable — you can stage multiple files:
```sh
convcommit --add src/auth.sh --add tests/auth_test.sh \
  -t test -s auth -m "add auth unit tests" -p
```

---

### Pipe mode — for CI and LLM/AI agents

When stdin is not a TTY, convcommit reads selections line by line.
Each line corresponds to a selector stage: type → scope → message.

```sh
printf "G\n.\nfix null pointer in login\n" | convcommit
```

Where `G` = fix (per the default letter assignment), `.` triggers free-text input for scope, and the next line is the typed message.

Combined with `--all` and `--push`:
```sh
printf "G\n.\nfix null pointer\n" | convcommit -a -p
```

To get just the formatted message (e.g. to inject into another tool):
```sh
msg=$(printf "G\n\nfix null pointer\n" | convcommit)
echo "$msg"
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
| `-V`, `--version` | Print version and exit |
| `-h`, `--help` | Print help and exit |

---

## Configuration — `.convcommit`

On first run, convcommit auto-creates a `.convcommit` file in the current directory.
You can commit this file to share the project's commit vocabulary with the team.

### Format

```
type:<value>      — commit type option
scope:<value>     — commit scope option
message:<value>   — commit message template
```

### Special prefixes

| Prefix | Effect |
|---|---|
| `~<value>` | Marks this entry as the default selection |
| `_` | Enables free-text manual input (press `.` in the menu) |
| `[X]<value>` | Forces letter `X` for this entry, skipping the sequential counter |

### Example `.convcommit`

```
type:[B]build
type:~chore
type:[D]docs
type:deps
type:feat
type:fix
type:[W]wip
scope:_
scope:~
message:_
message:~_
```

This produces:
`B`=build, `C`=chore, `D`=docs, `E`=deps, `F`=feat, `G`=fix, ... `W`=wip

The `[B]` and `[D]` forced letters skip `A` and jump over the sequential counter,
giving memorable mnemonics without chaotic assignments.

### Regenerate defaults

```sh
convcommit --reset
```

---

## Pre-flight checks

When running in interactive mode (stdout is a TTY), convcommit validates the environment before starting the selector — so you never waste time building a message only to fail at the git step:

- **Before committing**: checks there are staged/unstaged changes to commit
- **Before pushing**: checks a remote is configured and the branch is not behind

---

## Developer experience tips

**Full release workflow in one command:**
```sh
convcommit -a -p
```

**Commit a built binary with a typed message:**
```sh
convcommit --add bin/mytool -t build -s bin -m "update binary" -p
```

**Let an AI agent (Claude Code, etc.) commit without interaction:**
```sh
convcommit --type feat --scope ui --message "add dark mode toggle" --all --push
```

**Use `--reset` when the project defaults evolve:**
```sh
convcommit --reset   # removes .convcommit so it's recreated with latest defaults
```

**Customize scopes for your project in `.convcommit`:**
```
scope:~
scope:_
scope:api
scope:auth
scope:ui
scope:db
scope:ci
```

This gives your team a curated, project-specific scope vocabulary while still allowing free text via `_`.

---

## Contributing

We welcome contributions! Feel free to fork the repository, submit pull requests, or open issues for any improvements or bug fixes.

## License

This project is licensed under the MIT License.
