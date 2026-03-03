# convcommit

**convcommit** is a lightweight command-line tool that helps enforce [Conventional Commits](https://www.conventionalcommits.org/) in your Git workflow. It provides an interactive way to structure your commit messages according to best practices, improving readability and automation compatibility.

## Features

- Interactive commit message selection
- Supports all Conventional Commit types
- Optionally commits all changes (`-a/--all` flag)
- Supports automatic push (`-p/--push` flag)
- Ensures structured and meaningful Git commit messages
- Helps maintain a clean and consistent commit history

## Installation

You can install **convcommit** using [Mush](https://github.com/javanile/mush):

```sh
mush install convcommit
```

Alternatively, you can clone the repository and use it directly:

```sh
git clone https://github.com/yourusername/convcommit.git
cd convcommit
chmod +x convcommit
```

## Usage

Run `convcommit` to start an interactive commit message selection process:

```sh
convcommit
```

### Options

- `-a`, `--all`  → Automatically add all changes before committing.
- `-p`, `--push` → Push the commit to the remote repository after committing.

### Example

```sh
convcommit -a -p
```

This will:
1. Prompt you to select a commit type, scope, and message.
2. Commit all changes using the selected message.
3. Push the commit to the remote repository.

## Configuration

By default, `convcommit` stores available commit types and scopes in a `.convcommit` file. The first time you run it, this file will be created if it does not exist.

You can modify `.convcommit` to customize commit types, scopes, and message templates.

## Why Use convcommit?

- Keeps your commit messages standardized.
- Makes it easier to generate changelogs and automate release processes.
- Helps maintain a clean and readable Git history.

## Contributing

We welcome contributions! Feel free to fork the repository, submit pull requests, or open issues for any improvements or bug fixes.

## License

This project is licensed under the MIT License.

