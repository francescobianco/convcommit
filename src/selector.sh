

convcommit_selector() {
  local convcommit_file
  local stage
  local has_manual_input
  local input
  local key
  local columns
  local columns_width
  local default_value
  local field
  local forced_letter
  local marker
  local stage_upper
  local r b gy tx yw mp gn bd

  convcommit_file="$1"
  stage="$2"
  columns="${3:-1}"
  columns_width="${4:-80}"

  # Capture color sequences once (empty strings when --no-color)
  r="$(cc_reset)"
  b="$(cc_blue)"
  gy="$(cc_gray)"
  tx="$(cc_text)"
  yw="$(cc_yellow)"
  mp="$(cc_mauve)"
  gn="$(cc_green)"
  bd="$(cc_bold)"

  stage_upper=$(echo "$stage" | tr '[:lower:]' '[:upper:]')
  printf "${gy}── ${r}${bd}${b}Select commit %s${r}${gy} ──────────────────────────────────────────${r}\n" "$stage_upper" >&2

  index=64
  column=0
  default_value=
  while read -r line; do
    prefix=$(echo "${line}" | cut -d ':' -f 1)
    value=$(echo "${line}" | cut -d ':' -f 2)

    [ "${prefix}" != "${stage}" ] && continue

    # Extract forced letter: [X]value syntax
    forced_letter=
    case "$value" in
      \[?\]*)
        forced_letter=$(echo "$value" | cut -c2 | tr '[:lower:]' '[:upper:]')
        value=$(echo "$value" | cut -c4-)
        ;;
    esac

    if [ "${value#\~}" != "$value" ]; then
      value="${value#\~}"
      default_value="${value}"
    fi

    if [ "${value}" = "_" ]; then
      has_manual_input=true
      continue
    fi

    [ -z "${value}" ] && continue

    if [ -n "$forced_letter" ]; then
      index=$(printf '%d' "'${forced_letter}")
      letter="$forced_letter"
    else
      index=$((index + 1))
      letter=$(printf "%b" "\\$(printf '%03o' "$index")")
    fi

    marker="${gy} ${r}"
    [ "${value}" = "${default_value}" ] && marker="${yw}★${r}"

    column=$((column + 1))
    printf "%s${gy}[${r}${b}%s${r}${gy}]${r} ${tx}%-${columns_width}s${r}" "$marker" "$letter" "$value" >&2
    if [ "${column}" -eq "${columns}" ]; then
      column=0
      printf "\n" >&2
    fi
  done < "${convcommit_file}"

  [ "${column}" -ne 0 ] && printf "\n" >&2

  if [ "${index}" -gt 64 ]; then
    input=${default_value}
    [ "${default_value}" = "_" ] && default_value="[manual input]"
    [ -n "${has_manual_input}" ] && printf " ${gy}[${r}${mp}.${r}${gy}]${r} ${gy}free text${r}\n" >&2
    printf "${gy}Choose ${r}${bd}${b}%s${r}${gy} (default: ${r}${yw}%s${r}${gy}):${r} " "$stage" "${default_value:-[empty]}" >&2
    if [ -t 0 ]; then
      stty -icanon -echo
      key=$(dd bs=1 count=1 2>/dev/null | tr '[:lower:]' '[:upper:]')
      stty icanon echo
    else
      read -r key
      key=$(echo "$key" | tr '[:lower:]' '[:upper:]')
    fi
    echo "" >&2
    index=64
    while read -r line; do
      prefix=$(echo "${line}" | cut -d ':' -f 1)
      value=$(echo "${line}" | cut -d ':' -f 2)
      [ "${prefix}" != "${stage}" ] && continue

      # Extract forced letter: [X]value syntax
      forced_letter=
      case "$value" in
        \[?\]*)
          forced_letter=$(echo "$value" | cut -c2 | tr '[:lower:]' '[:upper:]')
          value=$(echo "$value" | cut -c4-)
          ;;
      esac

      [ "${value#\~}" != "$value" ] && value="${value#\~}"
      [ "${value}" = "_" ] && continue
      [ -z "${value}" ] && continue

      if [ -n "$forced_letter" ]; then
        index=$(printf '%d' "'${forced_letter}")
        letter="$forced_letter"
      else
        index=$((index + 1))
        letter=$(printf "%b" "\\$(printf '%03o' "$index")")
      fi

      [ "${key}" = "${letter}" ] && input="${value}"
    done < "${convcommit_file}"
  elif [ -n "${has_manual_input}" ]; then
    key="."
  fi

  if [ "${key}" = "." ] || [ "${input}" = "_" ]; then
    if [ -t 2 ]; then
      tput cuu1 >&2
      tput el >&2
    fi
    printf "${yw}⟩${r} ${gy}Type %s:${r} " "$stage" >&2
    read -r input
    echo "${stage}:${input}" | sed 's/\([^ =]\+\)=\([^ ]*\)/\1=?/g' >> "${convcommit_file}"
  fi

  if [ -t 2 ]; then
    tput cuu1 >&2
    tput el >&2
  fi

  printf "${gn}✓${r} ${b}%s${r}  ${bd}${tx}%s${r}\n" "$stage" "${input:-[empty]}" >&2

  echo "" >&2

  if echo "${input}" | grep -qi '[a-z][a-z]*=?'; then
    while echo "${input}" | grep -qi '[a-z][a-z]*=?'; do
      field=$(echo "${input}" | grep -oi '[a-z][a-z]*=?' | head -n 1 | cut -d= -f1)
      printf "${yw}⟩${r} ${gy}Insert value for '${r}${b}%s${r}${gy}':${r} " "$field" >&2
      read -r value
      # shellcheck disable=SC2001
      input=$(echo "${input}" | sed "s/\($field\)=?/\1 $value/")
    done

    echo "" >&2
  fi

  # shellcheck disable=SC2001
  input=$(echo "${input}" | sed 's/\([^ =]\+\)=\([^ ]*\)/\1 \2/g')

  echo "${input}"
}
