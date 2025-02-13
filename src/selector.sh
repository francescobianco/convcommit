

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

  convcommit_file="$1"
  stage="$2"
  columns="${3:-1}"
  columns_width="${4:-80}"

  echo "==> Select ${stage}" >&2

  index=64
  column=0
  default_value=
  while read -r line; do
    prefix=$(echo "${line}" | cut -d ':' -f 1)
    value=$(echo "${line}" | cut -d ':' -f 2)

    [ "${prefix}" != "${stage}" ] && continue

    if [ "${value#\~}" != "$value" ]; then
      value="${value#\~}"
      default_value="${value}"
    fi

    if [ "${value}" = "_" ]; then
      has_manual_input=true
      continue
    fi

    [ -z "${value}" ] && continue

    index=$((index + 1))
    column=$((column + 1))
    letter=$(printf "%b" "\\$(printf '%03o' "$index")")

    printf "[%s] %-${columns_width}s" "$letter" "$value" >&2
    if [ "${column}" -eq "${columns}" ]; then
      column=0
      printf "\n" >&2
    fi
  done < "${convcommit_file}"

  if [ "${index}" -gt 64 ]; then
    input=${default_value}
    [ "${default_value}" = "_" ] && default_value="[manual input]"
    [ -n "${has_manual_input}" ] && echo "[.] manual input" >&2
    echo -n "Choose commit ${stage} (default: ${default_value:-[empty]}): " >&2
    stty -icanon -echo
    key=$(dd bs=1 count=1 2>/dev/null | tr '[:lower:]' '[:upper:]')
    stty icanon echo
    echo "" >&2
    #echo "Pressed key: $key" >&2
    index=64
    while read -r line; do
      prefix=$(echo "${line}" | cut -d ':' -f 1)
      value=$(echo "${line}" | cut -d ':' -f 2)
      [ "${prefix}" != "${stage}" ] && continue
      [ "${value#\~}" != "$value" ] && value="${value#\~}"
      [ "${value}" = "_" ] && continue
      #[ -z "${input}" ] && input="${value}"
      index=$((index + 1))
      letter=$(printf "%b" "\\$(printf '%03o' "$index")")
      [ "${key}" = "${letter}" ] && input="${value}"
    done < "${convcommit_file}"
  elif [ -n "${has_manual_input}" ]; then
    key="."
  fi

  if [ "${key}" = "." ] || [ "${input}" = "_" ]; then
    tput cuu1 >&2
    tput el >&2
    echo -n "Manually type a ${stage}: " >&2
    read -r input
    echo "${stage}:${input}" | sed 's/\([^ =]\+\)=\([^ ]*\)/\1=?/g' >> "${convcommit_file}"
  fi

  tput cuu1 >&2
  tput el >&2

  echo "Selected commit ${stage}: ${input:-[empty]}" >&2

  echo "" >&2

  if echo "${input}" | grep -qi '[a-z][a-z]*=?'; then
    while echo "${input}" | grep -qi '[a-z][a-z]*=?'; do
      field=$(echo "${input}" | grep -oi '[a-z][a-z]*=?' | head -n 1 | cut -d= -f1)
      echo -n "Insert value for '${field}': " >&2
      read -r value
      input=$(echo "${input}" | sed "s/\($field\)=?/\1 $value/")
    done

    echo "" >&2
  fi

  input=$(echo "${input}" | sed 's/\([^ =]\+\)=\([^ ]*\)/\1 \2/g')

  echo "${input}"
}
