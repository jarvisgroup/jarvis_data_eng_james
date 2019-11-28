#! /bin/bash

#take command line argument and setup variable
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

lscpu_out=`lscpu`

#parse data and setup variable
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "Model name:" | awk '{$1=$2=""; print $0}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "CPU MHz:" | awk '{print $3}' | xargs)
L2_cache=$(echo "$lscpu_out"  | egrep "L2 cache:" | awk '{print $3}' | sed s'/K//' | xargs)
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date --rfc-3339=seconds | awk -F+ '{print $1}' | xargs)

#constuct insert statement
insert_statement="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, "timestamp") VALUES ('${hostname}', ${cpu_number}, '${cpu_architecture}', '${cpu_model}', ${cpu_mhz}, ${L2_cache}, ${total_mem}, '${timestamp}');"
#echo $insert_statement

#execute insert statement
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_statement"
