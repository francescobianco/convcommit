

convcommit_selector() {
  echo "Selector" >&2
  local convcommit_file
  local stage

  convcommit_file="$1"
  stage="$2"

  index=1
  while read line; do
    prefix=$(echo "${line}" | cut -d ':' -f 1)

    value=$(echo "${line}" | cut -d ':' -f 2)

    [ "${prefix}" != "${stage}" ] && continue

    echo "${index}. ${value}" >&2
    index=$((index + 1))
  done < "${convcommit_file}"

  echo -n "Choose commit ${stage}: " >&2
  stty -icanon -echo
  key=$(dd bs=1 count=1 2>/dev/null)
  stty icanon echo
  echo "" >&2
  echo "Hai premuto il tasto: $key" >&2


  echo $key
}
