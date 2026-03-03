
module init
module selector

usage() {
  echo "Usage: convcommit [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -t, --type <type>       Commit type (bypasses interactive selector)"
  echo "  -s, --scope <scope>     Commit scope (bypasses interactive selector)"
  echo "  -m, --message <msg>     Commit message (bypasses interactive selector)"
  echo "  -A, --add <file>        Stage a specific file (repeatable)"
  echo "  -a, --all               Stage all changes (git add .) before committing"
  echo "  -p, --push              Push to remote after committing"
  echo "      --reset             Regenerate .convcommit with latest defaults"
  echo "  -h, --help              Print this help and exit"
  echo ""
  echo "Non-interactive (pipe) usage:"
  echo "  printf 'F\n\nmy message\n' | convcommit"
  echo ""
  echo "Direct flags usage:"
  echo "  convcommit --type fix --scope auth --message 'fix null pointer'"
  echo "  convcommit -t feat -s api -m 'add endpoint' -a -p"
  echo "  convcommit --add src/foo.sh --add README.md -t docs -m 'update docs' -p"
}

main() {
  local commit_all
  local push
  local message
  local commit_message
  local commit_type
  local commit_scope
  local convcommit_file
  local direct_type
  local direct_scope
  local direct_message
  local add_files

  while [ $# -gt 0 ]; do
    case "$1" in
      -*)
        case "$1" in
          -h|--help)
            usage; exit 0 ;;
          -V|--version)
            echo "convcommit 0.1.0"; exit 0 ;;
          -a|--all)
            commit_all=true
            ;;
          -p|--push)
            push=true
            ;;
          -A|--add)
            add_files="${add_files} $2"; shift ;;
          -t|--type)
            direct_type="$2"; shift ;;
          -s|--scope)
            direct_scope="$2"; shift ;;
          -m|--message)
            direct_message="$2"; shift ;;
          --reset)
            rm -f ".convcommit"
            ;;
          *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        esac
        ;;
      *)
        break
        ;;
    esac
    shift
  done || true

  # Pre-flight checks — only in interactive/commit mode (stdout is a TTY).
  # Skipped when stdout is captured (msg=$(convcommit ...)) to allow message injection.
  if [ -t 1 ]; then
    if [ -n "$commit_all" ] || [ -n "$add_files" ]; then
      if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
        echo "error: nothing to commit, working tree clean" >&2
        exit 1
      fi
    fi
    if [ -n "$push" ]; then
      if ! git remote | grep -q '.'; then
        echo "error: no remote configured" >&2
        exit 1
      fi
      local behind
      behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
      if [ "$behind" -gt 0 ]; then
        echo "error: branch is behind remote by ${behind} commit(s), run 'git pull' first" >&2
        exit 1
      fi
    fi
  fi

  convcommit_file=".convcommit"

  convcommit_init_file "${convcommit_file}"

  commit_type=${direct_type:-$(convcommit_selector "$convcommit_file" "type" 4 10)}
  commit_scope=${direct_scope:-$(convcommit_selector "$convcommit_file" "scope")}
  commit_message=${direct_message:-$(convcommit_selector "$convcommit_file" "message")}

  if [ -n "${commit_scope}" ]; then
    message="${commit_type}(${commit_scope}): ${commit_message}"
  else
    message="${commit_type}: ${commit_message}"
  fi

  if [ -n "$add_files" ]; then
    # shellcheck disable=SC2086
    git add $add_files
    git commit -m "${message}" && true
  elif [ -n "$commit_all" ]; then
    git add .
    git commit -am "${message}" && true
  else
    echo "${message}"
  fi

  if [ -n "$push" ]; then
    git config credential.helper 'cache --timeout=3600'
    git push
  fi
}
