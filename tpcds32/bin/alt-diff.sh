#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

WORD_DIFF="false"

while getopts "w" opt; do
  case ${opt} in
    w )
      WORD_DIFF="true"
      if ! which wdiff > /dev/null; then
          sudo apt-update
          sudo apt-get -y install wdiff
      fi
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

for lq in "${BASE_DIR}"/query_variants_local/*.tpl; do
    query_name=$(basename "${lq}" L.tpl)
    q="${BASE_DIR}/query_templates/${query_name}.tpl"

    echo "===================================================================="
    if [ "$WORD_DIFF" = "true" ]; then
        wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' "${q}" "${lq}"
    else
        diff -u "${q}" "${lq}"
    fi
done
