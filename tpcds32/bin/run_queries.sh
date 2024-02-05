#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

SUFFIX=""

while getopts ":x:" opt; do
  case ${opt} in
    x )
      SUFFIX=$OPTARG
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



LOG4J_CONF="${BASE_DIR}/misc/log4j2.xml"

DRIVER_OPTIONS="--driver-memory 4g --driver-java-options -Dlog4j.configurationFile=file:///${LOG4J_CONF}"
EXECUTOR_OPTIONS="--executor-memory 2g --num-executors 1 --conf spark.executor.extraJavaOptions=-Dlog4j.configurationFile=file:///${LOG4J_CONF} --conf spark.sql.crossJoin.enabled=true"

rm -rf "${BASE_DIR}"/output/*

# Run the TPC-DS queries
for q in "${BASE_DIR}"/gen_queries/*${SUFFIX}.sql; do
    query_name=$(basename "${q}" .sql)
    echo "Running query: ${query_name}"
    spark-sql \
        --master ${SPARK_MASTER_URL} \
        --database tpcds \
        ${DRIVER_OPTIONS} \
        ${EXECUTOR_OPTIONS} \
        -f "${q}" \
        &> "${BASE_DIR}/output/${query_name}.out"
done