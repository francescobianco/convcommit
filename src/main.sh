
module selector

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

  while [ $# -gt 0 ]; do
    case "$1" in
      -*)
        case "$1" in
          -a|--all)
            commit_all=true
            ;;
          -p|--push)
            push=true
            ;;
          -t|--type)
            direct_type="$2"; shift ;;
          -s|--scope)
            direct_scope="$2"; shift ;;
          -m|--message)
            direct_message="$2"; shift ;;
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

  convcommit_file=".convcommit"

  if [ ! -f "${convcommit_file}" ]; then
    # shellcheck disable=SC2129
    echo "# convcommit - Conventional Commit message builder" >> "${convcommit_file}"
    echo "# This file is read by the \`convcommit\` CLI tool to populate" >> "${convcommit_file}"
    echo "# the interactive selector menus." >> "${convcommit_file}"
    echo "#" >> "${convcommit_file}"
    echo "# FORMAT" >> "${convcommit_file}"
    echo "#   type:<value>      — commit type option (e.g. fix, feat, docs)" >> "${convcommit_file}"
    echo "#   scope:<value>     — commit scope option" >> "${convcommit_file}"
    echo "#   message:<value>   — commit message template" >> "${convcommit_file}"
    echo "#" >> "${convcommit_file}"
    echo "# SPECIAL PREFIXES" >> "${convcommit_file}"
    echo "#   ~<value>          — marks the default selection" >> "${convcommit_file}"
    echo "#   _                 — enables free-text manual input (press \".\")" >> "${convcommit_file}"
    echo "#" >> "${convcommit_file}"
    echo "# HOW TO USE (interactive)" >> "${convcommit_file}"
    echo "#   Run \`convcommit\` in a git repo. A menu appears for type, scope, message." >> "${convcommit_file}"
    echo "#   Press the letter shown in brackets [A][B]... or [.] for manual input." >> "${convcommit_file}"
    echo "#" >> "${convcommit_file}"
    echo "# HOW TO USE (AI agent / non-interactive pipe)" >> "${convcommit_file}"
    echo "#   Pipe selections as lines, one per stage (type, scope, message)." >> "${convcommit_file}"
    echo "#   Use the letter shown in the menu, or \".\" to trigger manual input." >> "${convcommit_file}"
    echo "#   Example:" >> "${convcommit_file}"
    echo "#     printf \"A\n.\nfix null pointer in login\n\" | convcommit" >> "${convcommit_file}"
    echo "#   Or use direct flags to bypass the selector entirely:" >> "${convcommit_file}"
    echo "#     convcommit --type fix --scope auth --message \"fix null pointer\"" >> "${convcommit_file}"
    echo "type:fix" >> "${convcommit_file}"
    echo "type:build" >> "${convcommit_file}"
    echo "type:~chore" >> "${convcommit_file}"
    echo "type:docs" >> "${convcommit_file}"
    echo "type:merge" >> "${convcommit_file}"
    echo "type:feat" >> "${convcommit_file}"
    echo "type:style" >> "${convcommit_file}"
    echo "type:refactor" >> "${convcommit_file}"
    echo "type:perf" >> "${convcommit_file}"
    echo "type:test" >> "${convcommit_file}"
    echo "type:ci" >> "${convcommit_file}"
    echo "type:revert" >> "${convcommit_file}"
    echo "type:security" >> "${convcommit_file}"
    echo "type:deps" >> "${convcommit_file}"
    echo "type:wip" >> "${convcommit_file}"
    echo "type:init" >> "${convcommit_file}"
    echo "scope:_" >> "${convcommit_file}"
    echo "scope:~" >> "${convcommit_file}"
    echo "message:_" >> "${convcommit_file}"
    echo "message:~_" >> "${convcommit_file}"
  fi

  commit_type=${direct_type:-$(convcommit_selector "$convcommit_file" "type" 4 10)}
  commit_scope=${direct_scope:-$(convcommit_selector "$convcommit_file" "scope")}
  commit_message=${direct_message:-$(convcommit_selector "$convcommit_file" "message")}

  if [ -n "${commit_scope}" ]; then
    message="${commit_type}(${commit_scope}): ${commit_message}"
  else
    message="${commit_type}: ${commit_message}"
  fi

  if [ -n "$commit_all" ]; then
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
