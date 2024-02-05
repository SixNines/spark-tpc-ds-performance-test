#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

"${BASE_DIR}"/bin/make_spark_ddl.sh

spark-sql \
    --master $SPARK_MASTER_URL \
    -e "drop database if exists tpcds cascade; create database tpcds;"

for f in "${BASE_DIR}"/ddl/spark/*.sql; do
    spark-sql \
        --master $SPARK_MASTER_URL \
        --database tpcds \
        -f $f
done
