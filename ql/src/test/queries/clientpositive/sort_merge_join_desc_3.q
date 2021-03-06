--! qt:dataset:src
drop table table_desc1_n0;
drop table table_desc2_n0;



create table table_desc1_n0(key string, value string) clustered by (key, value)
sorted by (key DESC, value ASC) into 1 BUCKETS;
create table table_desc2_n0(key string, value string) clustered by (key, value)
sorted by (key DESC, value ASC) into 1 BUCKETS;

insert overwrite table table_desc1_n0 select key, value from src;
insert overwrite table table_desc2_n0 select key, value from src;

set hive.optimize.bucketmapjoin = true;
set hive.optimize.bucketmapjoin.sortedmerge = true;
set hive.input.format = org.apache.hadoop.hive.ql.io.BucketizedHiveInputFormat;
set hive.cbo.enable=false;
-- The columns of the tables above are sorted in same orders.
-- descending followed by ascending
-- So, sort merge join should be performed

explain
select /*+ mapjoin(b) */ count(*) from table_desc1_n0 a join table_desc2_n0 b
on a.key=b.key and a.value=b.value where a.key < 10;

select /*+ mapjoin(b) */ count(*) from table_desc1_n0 a join table_desc2_n0 b
on a.key=b.key and a.value=b.value where a.key < 10;

