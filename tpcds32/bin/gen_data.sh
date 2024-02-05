#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

SCALE=1

while getopts ":s:" opt; do
  case ${opt} in
    s )
      SCALE=$OPTARG
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

rm -rf "${BASE_DIR}"/gen_data/*
dsdgen -dir "${BASE_DIR}"/gen_data -scale $SCALE -verbose y -terminate n -dist "${BASE_DIR}"/misc/tpcds.idx -force