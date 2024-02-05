#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

for q in "${BASE_DIR}"/query_variants_local_work/*.tpl; do
    query_name=$(basename "${q}" .tpl)
    cp "${BASE_DIR}"/query_variants_local_work/${query_name}.tpl "${BASE_DIR}"/query_variants_local/${query_name}L.tpl
done