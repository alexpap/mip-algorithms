requirevars 'defaultDB' 'input_local_tbl' 'variable';

drop table if exists inputlocaltbl;
create table inputlocaltbl as
select __rid as rid, __colname as colname, tonumber(__val)  as val
from %{input_local_tbl}
where colname = '%{variable}';

var 'categorical' from
select case when (select count(distinct val) from inputlocaltbl)< 20 then "True" else "False" end;

var 'valIsText' from
select case when (select typeof(val) from inputlocaltbl limit 1) ='text' then "True" else "False" end;

select *
from ( select colname,
              val,
              FSUM(val) as S1,
              FSUM(FARITH('*', val, val)) as S2,
              count(val) as N
       from ( select * from inputlocaltbl where '%{categorical}'='True' and '%{valIsText}'='False')
       where val <> 'NA' and val is not null and val <> ""
       group by val
)

union all
select *
from ( select colname,
              val,
              FSUM(val) as S1,
              FSUM(FARITH('*', val, val)) as S2,
              count(val) as N
       from ( select * from inputlocaltbl where '%{categorical}'='False' and '%{valIsText}'='False')
       where val <> 'NA' and val is not null and val <> ""
)

union all
select *
from ( select colname,
              val,
              1 as S1,
              1 as S2,
              count(val) as N
       from ( select * from inputlocaltbl where '%{valIsText}'='True')
             where val <> 'NA' and val is not null and val <> ""
       where val is 'NA' or val is null or val == ""
       group by val
)

union all
select *
from ( select colname,
              "NA" as val,
               1 as S1,
               1 as S2,
              count(val) as N
       from inputlocaltbl
       where val is 'NA' or val is null or val == ""
);





