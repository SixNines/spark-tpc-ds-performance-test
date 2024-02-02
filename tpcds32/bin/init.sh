#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

spark-sql --master $SPARK_MASTER_URL -f <(echo "create database TPCDS;")
for f in "${BASE_DIR}"/ddl/spark/*.sql; do
    spark-sql --master $SPARK_MASTER_URL -f $f
done
