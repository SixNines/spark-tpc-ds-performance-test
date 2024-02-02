#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

# This code:
# 1. Removes comments and empty lines from the official TPC-DS DDL file
# 2. Converts the DDL to Spark SQL syntax
# 3. Writes the Spark SQL DDL to individual files in the ddl/spark directory
# 4. Converts CHAR and VARCHAR to STRING
# 5. Converts DECIMAL to DOUBLE
# 6. Removes NOT NULL constraints
# 7. Removes PRIMARY KEY constraints
# might need to convert date to string.  The IBM code does that.
for f in tpcds tpcds_source; do
    grep -v '^--' "${BASE_DIR}"/ddl/official/${f}.sql | grep -v '^);' |
        sed -E \
            -e '/^ *$/d' \
            -e 's/ +, *$/,/g' \
            -e 's/( +)(date|time)(,?)/\1string\3/g' \
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

sql_file="${BASE_DIR}"/ddl/spark/tables.sql
printf "use TPCDS;\n" > "${sql_file}"

for f in "${BASE_DIR}"/ddl/spark/*.tmp; do
    table_name=$(basename "${f}" .tmp)
    echo "drop table if exists ${table_name};" >> "${sql_file}"
    sed "s/${table_name}/${table_name}_text/g" "${f}" >> "${sql_file}"
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
