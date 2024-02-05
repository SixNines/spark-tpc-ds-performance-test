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


# We're using the alternate queries where available since they work with Apache Spark.
# We're combining the templates and alternates into a single directory and deleting the
# templates that have alternates.

vdir="query_variants_local"
vsuffix="L"

if [ ! -d "${BASE_DIR}"/query_tmp ]; then
    mkdir -p "${BASE_DIR}"/query_tmp
else
    rm -rf "${BASE_DIR}"/query_tmp/*
fi

cp "${BASE_DIR}"/query_templates/*.tpl "${BASE_DIR}"/query_tmp/
cp "${BASE_DIR}"/${vdir}/*.tpl "${BASE_DIR}"/query_tmp/

for qa in "${BASE_DIR}"/query_tmp/query*${vsuffix}.tpl; do
    query_name=$(basename "${qa}" ${vsuffix}.tpl)
    rm -f "${BASE_DIR}"/query_tmp/${query_name}.tpl
done

# Generate the queries into individual files.

if [ ! -d "${BASE_DIR}"/gen_queries ]; then
    mkdir -p "${BASE_DIR}"/gen_queries
else
    rm -rf "${BASE_DIR}"/gen_queries/*
fi

for q in "${BASE_DIR}"/query_tmp/query*.tpl; do
    query_name=$(basename "${q}" .tpl)
    dsqgen \
        -template "$(basename $q)" \
        -directory "${BASE_DIR}"/query_tmp \
        -dialect netezza \
        -scale $SCALE \
        -output "${BASE_DIR}"/gen_queries \
        -dist "${BASE_DIR}"/misc/tpcds.idx
    mv "${BASE_DIR}"/gen_queries/query_0.sql "${BASE_DIR}"/gen_queries/${query_name}.sql
done
