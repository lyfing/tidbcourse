#!bin/sh


function oltp_point_select(){
    t=$1
    log_file="oltp_point_select.${t}threads.log"
    sysbench --config-file=sysbench.conf oltp_point_select --threads=$t --tables=32 --table-size=100000 run > $log_file
}

function oltp_read_only(){
    t=$1
    log_file="oltp_read_only.${t}threads.log"
    sysbench --config-file=sysbench.conf oltp_read_only --threads=$t --tables=32 --table-size=100000 run > $log_file
}

function oltp_update_index(){
    t=$1
    log_file="oltp_update_index.${t}threads.log"
    sysbench --config-file=sysbench.conf oltp_update_index --threads=$t --tables=32 --table-size=100000 run > $log_file
}

for i in 8 16 32 64 128
do
    oltp_point_select $i
    sleep 30

    oltp_read_only $i
    sleep 30

    oltp_update_index $i
    sleep 30
done
