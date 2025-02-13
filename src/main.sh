
module selector

main() {
  local commit_all
  local push
  local message
  local commit_message
  local commit_type
  local commit_scope
  local convcommit_file

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
    echo "type:fix" >> "${convcommit_file}"
    echo "type:build" >> "${convcommit_file}"
    echo "type:chore" >> "${convcommit_file}"
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

  #commit_type=$(convcommit_selector "$convcommit_file" "type" 4 10)
  #commit_scope=$(convcommit_selector "$convcommit_file" "scope")
  commit_message=$(convcommit_selector "$convcommit_file" "message")

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
