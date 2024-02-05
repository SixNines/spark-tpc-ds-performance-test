#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

if [ ! -d "${BASE_DIR}"/ddl/spark ]; then
    mkdir -p "${BASE_DIR}"/ddl/spark
else
    rm -rf "${BASE_DIR}"/ddl/spark/*
fi 

# 1. Removes comments and empty lines from the official TPC-DS DDL file
# 2. Writes the Spark SQL DDL to individual .tmp files in the ddl/spark directory
# 3. Converts CHAR, VARCHAR, DATE, TIME to STRING
# 4. Converts DECIMAL to DOUBLE
# 5. Removes NOT NULL constraints
# 6. Removes PRIMARY KEY constraints
for f in tpcds tpcds_source; do
    grep -v '^--' "${BASE_DIR}"/ddl/official/${f}.sql | grep -v '^);' |
        sed -E \
            -e '/^ *$/d' \
            -e 's/ +, *$/,/g' \
            -e 's/( +)(date|time)(,? *)$/\1string\3/g' \
            -e 's/(char|varchar)\([0-9]+\)/string/g' \
            -e 's/decimal\(.+\)/double/g' \
            -e 's/ not null//g' |
        awk \
            -v tableName="none" \
            -v baseDir="${BASE_DIR}/ddl/spark" \
            '{
                if(NR > 1 && prevLine ~ /,$/ && $0 ~ /primary key/){
                    sub(/,$/, "", prevLine);
                }
                if(NR > 1 && prevLine !~ /primary key/){
                    print prevLine > (baseDir "/" tableName ".tmp");
                }
                if($0 ~ /create table/){tableName=$3};
                prevLine = $0;
            }
            END {
                if(prevLine !~ /primary key/){
                    print prevLine > (baseDir "/" tableName ".tmp");
                }
            }'
done

# Create the final Spark SQL DDL file
sql_file="${BASE_DIR}"/ddl/spark/tables.sql
rm -f "${sql_file}"

# For each table, create a text table, load the data, create a parquet table, and drop the text table
for f in "${BASE_DIR}"/ddl/spark/*.tmp; do
    table_name=$(basename "${f}" .tmp)
    echo "drop table if exists ${table_name};" >> "${sql_file}"
    sed "s/create table ${table_name}/create table ${table_name}_text/g" "${f}" >> "${sql_file}" # temp table has _text suffix
    cat <<EOF >> "${sql_file}"
)
USING csv
OPTIONS(header "false", delimiter "|", path "${BASE_DIR}/gen_data/${table_name}.dat");

drop table if exists ${table_name};
create table ${table_name} 
using parquet
as (select * from ${table_name}_text);

drop table if exists ${table_name}_text;

EOF
done

rm -rf "${BASE_DIR}"/ddl/spark/*.tmp
