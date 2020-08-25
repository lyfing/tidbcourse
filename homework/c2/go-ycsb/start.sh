#!/bin/sh

GO_YCSB_PATH="/data/soft/go-ycsb"

for i in workloada workloadb workloadc workloadd workloade workloadf
do
    #load data
    load_log_file="${i}-load.log"
    $GO_YCSB_PATH/bin/go-ycsb load mysql -P $GO_YCSB_PATH/workloads/$i -P ycsb.conf -p recordcount=100000 --threads 8 > $load_log_file
    for j in 8 1632 64 128
    do
	log_file="${i}-${j}threads.log"
        $GO_YCSB_PATH/bin/go-ycsb run mysql -P $GO_YCSB_PATH/workloads/$i -P ycsb.conf -p recordcount=100000 --threads $j > $log_file
        sleep 30
    done 
done
