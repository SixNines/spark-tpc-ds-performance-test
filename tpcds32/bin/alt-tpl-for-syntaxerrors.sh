#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

mkdir -p "${BASE_DIR}"/query_variants_local_work
rm -rf "${BASE_DIR}"/query_variants_local_work/*

files_with_errors=$(grep -ril "syntax error" "${BASE_DIR}"/output/*)

# Copy matching files with a .TPL extension from the query templates folder to the query alternative folder
for file_with_error in $files_with_errors; do
    base_file_name=$(basename "$file_with_error" .out)
    cp "$file_with_error" "$BASE_DIR/query_variants_local_work"
    cp "$BASE_DIR/query_templates/$base_file_name.tpl" "$BASE_DIR/query_variants_local_work"
done
