

convcommit_selector() {
  local convcommit_file
  local stage
  local has_manual_input
  local input
  local key

  convcommit_file="$1"
  stage="$2"

  echo "" >&2
  echo "=========[ SELECT ${stage} ]=========" >&2

  index=64
  while read line; do
    prefix=$(echo "${line}" | cut -d ':' -f 1)

    value=$(echo "${line}" | cut -d ':' -f 2)

    [ "${prefix}" != "${stage}" ] && continue
    if [ "${value}" = "_" ]; then
      has_manual_input=true
      continue
    fi

    index=$((index + 1))
    letter=$(printf "\\$(printf '%03o' ${index})")
    echo "[${letter}] ${value}" >&2
  done < "${convcommit_file}"

  if [ "${index}" -gt 64 ]; then
    [ -n "${has_manual_input}" ] && echo "Press [space] for manual input" >&2
    echo -n "Choose commit ${stage}: " >&2
    stty -icanon -echo
    key=$(dd bs=1 count=1 2>/dev/null | tr '[:lower:]' '[:upper:]')
    stty icanon echo
    echo "" >&2
    index=64
    #echo "Hai premuto il tasto: $key" >&2
    while read line; do
        prefix=$(echo "${line}" | cut -d ':' -f 1)
        value=$(echo "${line}" | cut -d ':' -f 2)
        [ "${prefix}" != "${stage}" ] && continue
        [ "${value}" = "_" ] && continue
        index=$((index + 1))
        letter=$(printf "\\$(printf '%03o' ${index})")
        [ "$key" = "$letter" ] && input="${value}"
      done < "${convcommit_file}"
  elif [ -n "${has_manual_input}" ]; then
    key=" "
  fi

  if [ "${key}" = " " ]; then
    echo -n "Manually type a ${stage}: " >&2
    read input
    echo "${stage}:${input}" >> "${convcommit_file}"
  fi

  echo "${input}"
}
