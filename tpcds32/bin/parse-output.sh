#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

for o in "${BASE_DIR}"/output/*.out; do

    query_name=$(basename "${o}" .out)

    echo "===================================================================="
    echo "Query: ${query_name}"
    grep "Time taken" "${o}"

done