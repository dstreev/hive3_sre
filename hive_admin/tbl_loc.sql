SELECT
    d.name                                              as db_name
  , t.tbl_name
  , t.tbl_type
  , count(p.part_name)                                  as partition_count
  , regexp_extract(s.location, 'hdfs://([^/]+)(.*)', 2) AS tbl_location
FROM
    sys.dbs d
        inner join sys.tbls t on d.db_id = t.db_id
        left join sys.partitions p on t.tbl_id = p.tbl_id
        left outer join sys.sds s on t.sd_id = s.sd_id
WHERE
      (t.tbl_type = 'MANAGED_TABLE' OR t.tbl_type = 'EXTERNAL_TABLE')
  AND substr(s.location, 0, 4) = 'hdfs'
GROUP BY
    d.name, t.tbl_name, t.tbl_type, regexp_extract(s.location, 'hdfs://([^/]+)(.*)', 2);

