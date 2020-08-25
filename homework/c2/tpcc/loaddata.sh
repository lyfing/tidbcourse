#!/bin/sh

#####1.导入数据
current_dir=(`dirname $0`)
tpcc_bin=/data/soft/benchmarksql/run

####1.1建表
cd $tpcc_bin
./runSQL.sh props.mysql sql.mysql/tableCreates.sql
./runSQL.sh props.mysql sql.mysql/indexCreates.sql

####1.2导入数据
./runLoader.sh props.mysql

cd $current_dir
