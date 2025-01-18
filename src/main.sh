main() {
  local commit_all
  local push
  local message
  local commit_message
  local commit_type
  local commit_scope
  local convcommit_file
  local index
  local stage

  while [ $# -gt 0 ]; do
    case "$1" in
      -*)
        case "$1" in
          -a|--all)
            commit_all=true
            shift
            ;;
          -p|--push)
            push=true
            shift
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
    echo "type: feat" >> "${convcommit_file}"
  fi

  ##
  index=1
  stage=type
  cat "${convcommit_file}" | while read line; do
    prefix=$(echo "${line}" | cut -d ':' -f 1)

    value=$(echo "${line}" | cut -d ':' -f 2)

    [ "${prefix}" != "${stage}" ] && continue

    echo "${index}. ${value}"
    index=$((index + 1))
  done

  echo -n "Premi un tasto: "
  # Configura il terminale per leggere un carattere senza echo
  stty -icanon -echo
  key=$(dd bs=1 count=1 2>/dev/null)
  # Ripristina le impostazioni originali del terminale
  stty icanon echo
  echo
  echo "Hai premuto il tasto: $key"

  commit_type=
  commit_scope=
  commit_message=

  if [ -n "${commit_scope}" ]; then
    message="${commit_type}(${commit_scope}): ${commit_message}"
  else
    message="${commit_type}: ${commit_message}"
  fi

  if [ -n "$commit_all" ]; then
    git add .
    git commit -am "${message}" && true
  fi

  if [ -n "$push" ]; then
    git push
  fi
}
