# Hive Admin

Keeping a hadoop cluster healthy is an ongoing task.  Performance and reliability in Hive depend on a solid physical architecture and configuration.  But that's not the only driver affecting performance and reliability.

Table designs and Ingest patterns directly affect Hive performance, capabilities, and consistency.  Many *Hadoop Administrators* lack the tools and understanding to address these aspects of Hive.  I hope here to provide techniques and patterns to help *Hadoop Administrators* become the *Hive DBA's* that are so sorely missing from many Hadoop Big Data Installations.

## Small Files

## Know What's Behind your Tables

Find the tables with 'low' average file sizes.  The lower the average file size, the more work it takes to process.  The affect is variable run times and increased consumption requirements.

Identify the top tables and talk to the developers/owners about them.  Fix the ingest and/or design of these tables to build a better supporting persistence layer for Hive.

Using 'sys.db' in the Hive(3+) Metastore with [this query](./tbl_loc.sql) we can build a list of tables and their associated locations.  With this list, we run the `hdfs dfs -count` command on the directories to get count of folders, files, and total size.  Here we'll use a combination of the Hive [query](./tbl_loc.sql) and [Hadoop CLI](https://github.com/dstreev/hadoop-cli) (tested with HadoopCli 2.0.22+) to build this result quickly.

First, we'll show the [query](./tbl_loc.sql) results used in this process.
```
export HIVE_OUTPUT_OPTS="--showHeader=false --outputformat=dsv --delimiterForDSV=,"
export HIVE_ALIAS=hive

${HIVE_ALIAS} ${HIVE_OUTPUT_OPTS} -f tbl_loc.sql > result.txt
``` 

Sample Output

```
cat result.txt
...
airline_perf,airline_perf,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/airline_perf.db/airline_perf
airline_perf,airline_perf_ext_orc,EXTERNAL_TABLE,0,/warehouse/tablespace/external/hive/airline_perf_ext_orc.db/airline_perf_ext_orc
credit_card,cc_balance,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/credit_card.db/cc_balance
credit_card,cc_trans,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/credit_card.db/cc_trans
custom_sys,completed_compactions,EXTERNAL_TABLE,0,/warehouse/tablespace/external/hive/custom_sys.db/completed_compactions
default,dual,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/dual
default,hello,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/hello
default,test,MANAGED_TABLE,0,/apps/spark/warehouse/test
default,test,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/test
default,test_b,MANAGED_TABLE,0,/warehouse/tablespace/managed/hive/test_b
default,test_ext,EXTERNAL_TABLE,0,/user/dstreev/test_ext
demo_planning,dir_size_demo,EXTERNAL_TABLE,0,/warehouse/tablespace/external/hive/demo_planning.db/dir_size_demo
demo_planning,hms_dump_demo,EXTERNAL_TABLE,0,/warehouse/tablespace/external/hive/demo_planning.db/hms_dump_demo
...
```

Use this output to collect stats about each table directory in HDFS using the [Hadoop CLI](https://github.com/dstreev/hadoop-cli).

```$sh
$ hadoopcli -f result.txt -s -t "count {4}"
           2            3          304198533 /warehouse/tablespace/managed/hive/airline_perf.db/airline_perf
           1           54          419626791 /warehouse/tablespace/external/hive/airline_perf_ext_orc.db/airline_perf_ext_orc
           1            0                  0 /warehouse/tablespace/managed/hive/credit_card.db/cc_balance
           1            0                  0 /warehouse/tablespace/managed/hive/credit_card.db/cc_trans
           1            0                  0 /warehouse/tablespace/external/hive/custom_sys.db/completed_compactions
           2            2                644 /warehouse/tablespace/managed/hive/dual
           1            0                  0 /warehouse/tablespace/managed/hive/hello
           1            2                207 /apps/spark/warehouse/test
           1            0                  0 /warehouse/tablespace/managed/hive/test
           1            0                  0 /warehouse/tablespace/managed/hive/test_b
           1            3               1028 /user/dstreev/test_ext
           1            0                  0 /warehouse/tablespace/external/hive/demo_planning.db/dir_size_demo
           1            2           60846426 /warehouse/tablespace/external/hive/demo_planning.db/hms_dump_demo
           3            4               1766 /warehouse/tablespace/managed/hive/demo_planning.db/known_serdes_demo
           2            1             907009 /warehouse/tablespace/external/hive/demo_planning.db/paths_demo
           1            7            8491940 /warehouse/tablespace/external/hive/dstreev_01.db/basic_append
```

Or...  combine the two calls into a unix piped process

```$sh
export HIVE_OUTPUT_OPTS="--showHeader=false --outputformat=dsv --delimiterForDSV=,"
export HIVE_ALIAS=hive

${HIVE_ALIAS} ${HIVE_OUTPUT_OPTS} -f tbl_loc.sql | hadoopcli -s -stdin -t "count {4}"
```

There you have it.  A list of folders for tables in the Hive Metastore with files and folder counts, including overall data size.  Take that output, put it into Excel and calculate the *average* file size in each directory.  Rank the smallest average file size tables and *START HAVING DISCUSSIONS WITH YOU USERS*.

