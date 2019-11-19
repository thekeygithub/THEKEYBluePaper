P_DWD_V_D_KC21_KC22_KC24.sh：
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_KC21_KC22_KC24
#  *功能描述 --%@COMMENT:医疗保险结算综合
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: hby
#  *创建时间 --%@CREATED_TIME:20180426
#  *层次---%@LEVEL:DWD
#  *主题-%@MASTER_FIELD: 医疗(MED)
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:  KC21,KC22,KC24
#  *目标-%@TO:   DWD.DWD_V_D_KC21_KC22_KC24
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账期（yyyymm(dd)
##***************************************************************************
  v_date=$1
  v_pkg=dwd_CN
  v_procname=P_DWD_V_D_KC21_KC22_KC24
  v_tablename=DWD.DWD_V_D_KC21_KC22_KC24

##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date}' and procname= '${v_procname}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date}' and procname= '${v_procname}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
psql -d src -U sjcj -c" delete from  DWD.DWD_V_D_KC21_KC22_KC24_mid1 where day_id='${v_date}' ;"
psql -d src -U sjcj -c"
insert into DWD.DWD_V_D_KC21_KC22_KC24_mid1
select T1.AKB020 ,
T1.AKC190 ,
T1.AAE072 ,
T1.AKA135 ,
T1.AAE100 ,
T1.AAC001 ,
T1.AAB001 ,
T1.AKA130 ,
T1.AKC021 ,
T1.AKC197 ,
T1.AKC335 ,
T1.AKC336 ,
T1.AAE040 ,
T1.AKC264 ,
T1.AKC268 ,
T1.AKC253 ,
T1.AKC280 ,
T1.AKC255 ,
T1.AKC261 ,
T1.AAE011 ,
T2.AKC515 ,
T2.AKC516 ,
T2.AKC222 ,
T2.AKC223 ,
T2.AKC225 ,
T2.AKC226 ,
T2.AKC227 ,
T2.AKC228 ,
T2.AKC334 ,
T2.AKA064 ,
'' ,
'' ,
'',
'' ,
'' ,
'' ,
'',
'${v_date}',
T2.AKA063 ,
T2.AKA065 ,
T1.AAE036 ,
T2.AAE036 ,
T2.AKC220
from KC24 T1,KC22_fq_201801 T2
where 
T1.AKB020=T2.AKB020  AND
T1.AKC190=T2.AKC190  AND
T1.AAE072=T2.AAE072  AND
T1.AKA135=T2.AKA135  AND
T1.AAE100=T2.AAE100;"
psql -d src -U sjcj -c" delete from  DWD.DWD_V_D_KC21_KC22_KC24 where day_id='${v_date}' ;"
psql -d src -U sjcj -c"
insert into DWD.DWD_V_D_KC21_KC22_KC24
select 
T_MID.AKB020 ,
T_MID.AKC190 ,
T_MID.AAE072 ,
T_MID.AKA135 ,
T_MID.AAE100 ,
T_MID.AAC001 ,
T_MID.AAB001 ,
T_MID.AKA130 ,
T_MID.AKC021 ,
T_MID.AKC197 ,
T_MID.AKC335 ,
T_MID.AKC336 ,
T_MID.AAE040 ,
T_MID.AKC264 ,
T_MID.AKC268 ,
T_MID.AKC253 ,
T_MID.AKC280 ,
T_MID.AKC255 ,
T_MID.AKC261 ,
T_MID.AAE011 ,
T_MID.AKC515 ,
T_MID.AKC516 ,
T_MID.AKC222 ,
T_MID.AKC223 ,
T_MID.AKC225 ,
T_MID.AKC226 ,
T_MID.AKC227 ,
T_MID.AKC228 ,
T_MID.AKC334 ,
T_MID.AKA064 ,
T3.AKA101 ,
T3.AKC192 ,
T3.AKC193 ,
T3.AKC231 ,
T3.AKC194 ,
T3.AKC196 ,
T3.AKC232 ,
T_MID.day_id,
T3.AKC201,
T3.AKC202,
T_MID.AKA063 ,
T_MID.AKA065 ,
T_MID.kc24_AAE036 ,
T_MID.kc22_AAE036 ,
T3.AAE036 ,
T_MID.AKC220
FROM
(select T1.AKB020 ,
T1.AKC190 ,
T1.AAE072 ,
T1.AKA135 ,
T1.AAE100 ,
T1.AAC001 ,
T1.AAB001 ,
T1.AKA130 ,
T1.AKC021 ,
T1.AKC197 ,
T1.AKC335 ,
T1.AKC336 ,
T1.AAE040 ,
T1.AKC264 ,
T1.AKC268 ,
T1.AKC253 ,
T1.AKC280 ,
T1.AKC255 ,
T1.AKC261 ,
T1.AAE011 ,
T1.AKC515 ,
T1.AKC516 ,
T1.AKC222 ,
T1.AKC223 ,
T1.AKC225 ,
T1.AKC226 ,
T1.AKC227 ,
T1.AKC228 ,
T1.AKC334 ,
T1.AKA064 ,
T1.AKA063 ,
T1.AKA065 ,
T1.day_id ,
T1.kc24_AAE036 ,
T1.kc22_AAE036 ,
T1.AKC220 
from DWD.DWD_V_D_KC21_KC22_KC24_mid1 t1) T_MID,KC21 T3
where
T_MID.AKB020=T3.AKB020  AND
T_MID.AKC190=T3.AKC190  AND
T_MID.AKA135=T3.AKA135  AND
T_MID.AAE100=T3.AAE100;"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date}'
     and procname= '${v_procname}' ;"
P_DWD_V_D_KC24_KC22_NEW.sh：
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_KC24_KC22_NEW
#  *功能描述 --%@COMMENT:医疗保险结算综合
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: hby
#  *创建时间 --%@CREATED_TIME:20180508
#  *层次---%@LEVEL:DWD
#  *主题-%@MASTER_FIELD: 医疗(MED)
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM: KC22,KC24
#  *目标-%@TO:   DWD.DWD_V_D_KC24_KC22
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账期（yyyymm(dd)
##***************************************************************************
  v_date=$1
  v_pkg=dwd_CN
  v_procname=P_DWD_V_D_KC24_KC22_new
  v_tablename=DWD.DWD_V_D_KC24_KC22_new
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date '+%Y-%m-%d %H:%M:%S'`
v_fq=`echo  ${v_date}| cut -c 1-6`
echo  ${v_fq}
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date}' and procname= '${v_procname}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date}' and procname= '${v_procname}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
psql -d src -U sjcj -c" delete from DWD.DWD_V_D_KC24_KC22_new  where substr(day_id,1,6)='${v_fq}';"
psql -d src -U sjcj -c"
insert into DWD.DWD_V_D_KC24_KC22_new
select T1.AKB020 ,
T1.AKC190 ,
T1.AAE072 ,
T1.AKA135 ,
T1.AAE100 ,
T1.AAC001 ,
T1.AAB001 ,
T1.AKA130 ,
T1.AKC021 ,
T1.AKC197 ,
T1.AKC335 ,
T1.AKC336 ,
T1.AAE040 ,
T1.AKC264 ,
T1.AKC268 ,
T1.AKC253 ,
T1.AKC280 ,
T1.AKC255 ,
T1.AKC261 ,
T1.AAE011 ,
T2.AKC515 ,
T2.AKC516 ,
T2.AKC222 ,
T2.AKC223 ,
T2.AKC225 ,
T2.AKC226 ,
T2.AKC227 ,
T2.AKC228 ,
T2.AKC334 ,
T2.AKA064 ,
replace(substring(T1.AAE036 from 1 for 10),'-',''),
T2.AKA063 ,
T2.AKA065 ,
T1.aae036 ,
T2.aae036 ,
T2.akc220 ,
T2.AKC221 ,
T2.AKC201 ,
T2.AKC202
from KC24 T1,kc22_fq_${v_fq} T2
where 
T1.AKB020=T2.AKB020  AND
T1.AKC190=T2.AKC190  AND
T1.AAE072=T2.AAE072  AND
T1.AKA135=T2.AKA135  AND
T1.AAE100=T2.AAE100;"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date}'
     and procname= '${v_procname}' ;"
P_DWD_V_D_KC24_KC21.sh
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_KC24_KC21
#  *功能描述 --%@COMMENT:医疗保险结算综合
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: hby
#  *创建时间 --%@CREATED_TIME:20180508
#  *层次---%@LEVEL:DWD
#  *主题-%@MASTER_FIELD: 医疗(MED)
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:  KC21,KC24
#  *目标-%@TO:   DWD.DWD_V_D_KC24_KC21
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账期（yyyymm(dd)
##***************************************************************************
  v_date=$1
  v_pkg=dwd_CN
  v_procname=P_DWD_V_D_KC24_KC21
  v_tablename=DWD.DWD_V_D_KC24_KC21
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date}' and procname= '${v_procname}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date}' and procname= '${v_procname}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
psql -d src -U sjcj -c" truncate table  DWD.DWD_V_D_KC24_KC21 ;"
psql -d src -U sjcj -c"
insert into DWD.DWD_V_D_KC24_KC21
select T1.AKB020 ,
T1.AKC190 ,
T1.AAE072 ,
T1.AKA135 ,
T1.AAE100 ,
T1.AAC001 ,
T1.AAB001 ,
T1.AKA130 ,
T1.AKC021 ,
T1.AKC197 ,
T1.AKC335 ,
T1.AKC336 ,
T1.AAE040 ,
T1.AKC264 ,
T1.AKC268 ,
T1.AKC253 ,
T1.AKC280 ,
T1.AKC255 ,
T1.AKC261 ,
T1.AAE011 ,
T3.AKA101 ,
T3.AKC192 ,
T3.AKC193 ,
T3.AKC231 ,
T3.AKC194 ,
T3.AKC196 ,
T3.AKC232 ,
T3.AKC201,
T3.AKC202,
replace(substring(T1.AAE036 from 1 for 10),'-',''),
T1.AAE036 ,
T3.AAE036 ,
T3.AKC323 ,
T1.AKC265
from kc24 t1, KC21 T3
where
T1.AKB020=T3.AKB020  AND
T1.AKC190=T3.AKC190  AND
T1.AKA135=T3.AKA135  AND
T1.AAE100=T3.AAE100;"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date}'
     and procname= '${v_procname}' ;"
P_DWD_V_D_USER_AC02.SH：
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_USER_AC02
#  *功能描述 --%@COMMENT: 
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH    日期,格式YYYYMMDD
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DWD
#  *主题-%@MASTER_FIELD: 
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:  AC02
#  *目标-%@TO:    DWD.DWD_V_D_USER_AC02
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账期(yyyymmdd)
#          
##***************************************************************************
  v_date_id=$1
  v_pkg=P_DWD
  v_procname=P_DWD_V_D_USER_AC02
  v_tablename=DWD.DWD_V_D_USER_AC02
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date +'%Y%m%d%H%M%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date_id}' and procname= '${v_procname}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date_id}' and procname= '${v_procname}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date_id}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
v_sql="
----计算连续参保时间并插入中间表
delete from DWD.MID_V_D_USER_LX_TIME;
INSERT INTO DWD.MID_V_D_USER_LX_TIME
select aac001,
       SUM(case
             when aae140 = '3' then
              LX_TIME
           end) YB_LX_TIME,
       SUM(case
             when aae140 = '1' then
              LX_TIME
           end) YL_LX_TIME,
       SUM(case
             when aae140 = '2' then
              LX_TIME
           end) SY_LX_TIME,
       SUM(case
             when aae140 = '4' then
              LX_TIME
           end) GS_LX_TIME,
       SUM(case
             when aae140 = '5' then
              LX_TIME
           end) BR_LX_TIME
  from (SELECT *
          FROM (SELECT *,
                       ROW_NUMBER() OVER(PARTITION BY aac001, AAE140 ORDER BY aae041 DESC) RN
                  FROM (select aac001,
                               CASE
                                 WHEN SUBSTRING(aae140 FROM 1 FOR 1) = '3' THEN
                                  '3'
                                 WHEN SUBSTRING(aae140 FROM 1 FOR 1) = '1' THEN
                                  '1'
                                 WHEN SUBSTRING(aae140 FROM 1 FOR 1) = '2' THEN
                                  '2'
                                 WHEN SUBSTRING(aae140 FROM 1 FOR 1) = '4' THEN
                                  '4'
                                 WHEN SUBSTRING(aae140 FROM 1 FOR 1) = '5' THEN
                                  '5'
                               END AAE140,
                               aae041,
                               case
                                 when aae041 like '%.%' or length(aae041) < '6' then
                                  '0'
                                 when aae042 = '' then
                                  date_part('month',
                                            age(to_date(substring('${v_date_id}'
                                                                  ::character
                                                                  varying from 1 for 6),
                                                        'YYYYMM'),
                                                to_date(aae041, 'YYYYMM'))) +
                                  12 *
                                  date_part('year',
                                            age(to_date(substring('${v_date_id}'
                                                                  ::character
                                                                  varying from 1 for 6),
                                                        'YYYYMM'),
                                                to_date(aae041, 'YYYYMM')))
                                 when length(aae042) = '6' and
                                      length(aae041) = '6' then
                                  date_part('month',
                                            age(to_date(aae042, 'YYYYMM'),
                                                to_date(aae041, 'YYYYMM'))) +
                                  12 *
                                  date_part('year',
                                            age(to_date(aae042, 'YYYYMM'),
                                                to_date(aae041, 'YYYYMM')))
                                 else
                                  '0'
                               end LX_TIME
                          from ac02
                         GROUP BY aac001, AAE140, aae041, LX_TIME) A) B
         WHERE RN = 1) C
 GROUP BY aac001;
 "
 psql -d src -U sjcj -c "${v_sql}"
v_sql="
DELETE FROM DWD.MID_V_D_USER_LJ_TIME;
INSERT INTO DWD.MID_V_D_USER_LJ_TIME
  select aac001,
         max(case
               when substring(AAE140 from 1 for 1) = '3' then
                LJ_TIME
             end) YB_LJ_TIME,
         max(case
               when substring(AAE140 from 1 for 1) = '1' then
                LJ_TIME
             end) YL_LJ_TIME,
         max(case
               when substring(AAE140 from 1 for 1) = '2' then
                LJ_TIME
             end) SY_LJ_TIME,
         max(case
               when substring(AAE140 from 1 for 1) = '4' then
                LJ_TIME
             end) GS_LJ_TIME,
         max(case
               when substring(AAE140 from 1 for 1) = '5' then
                LJ_TIME
             end) BR_LJ_TIME
    from (
          select aac001, AAE140, sum(LJ_TIME) LJ_TIME
            from (
                   select aac001,
                           AAE140,
                           SUM(case
                                 when aae041 like '%.%' or length(aae041) < '6' then
                                  '0'
                                 when aae042 = '' then
                                  date_part('month',
                                            age(to_date(substring('${v_date_id}'
                                                                  ::character varying from 1 for 6),
                                                        'YYYYMM'),
                                                to_date(aae041, 'YYYYMM'))) +
                                  12 *
                                  date_part('year',
                                            age(to_date(substring('${v_date_id}'
                                                                  ::character varying from 1 for 6),
                                                        'YYYYMM'),
                                                to_date(aae041, 'YYYYMM')))
                                 when length(aae042) = '6' and length(aae041) = '6' then
                                  date_part('month',
                                            age(to_date(aae042, 'YYYYMM'),
                                                to_date(aae041, 'YYYYMM'))) +
                                  12 * date_part('year',
                                                 age(to_date(aae042, 'YYYYMM'),
                                                     to_date(aae041, 'YYYYMM')))
                                 else
                                  '0'
                               end) LJ_TIME
                     from ac02
                    GROUP BY aac001, AAE140) A
           GROUP BY aac001, AAE140) B
   GROUP BY aac001;
"
psql -d src -U sjcj -c "${v_sql}"
v_sql="   
DELETE FROM DWD.MID_V_D_USER_TIME;
insert into DWD.MID_V_D_USER_TIME
select aac001,
       max(yb_aae041),
       max(yb_aae042),
       max(yb_aac031),
       max(yb_aac037),
       max(yb_aac130),
       max(yb_aae036),
       max(sy_aae041),
       max(sy_aae042),
       max(sy_aac031),
       max(sy_aac037),
       max(sy_aac130),
       max(sy_aae036),
       max(yl_aae041),
       max(yl_aae042),
       max(yl_aac031),
       max(yl_aac037),
       max(yl_aac130),
       max(yl_aae036),
       max(gs_aae041),
       max(gs_aae042),
       max(gs_aac031),
       max(gs_aac037),
       max(gs_aac130),
       max(gs_aae036),
       max(br_aae041),
       max(br_aae042),
       max(br_aac031),
       max(br_aac037),
       max(br_aac130),
       max(br_aae036)
  from (
        select *
          from (select aac001,
                        aae041 yb_aae041,
                        aae042 yb_aae042,
                        aac031 yb_aac031,
                        aac037 yb_aac037,
                        aac130 yb_aac130,
                        aae036 yb_aae036,
                        '' ::character varying as sy_aae041,
                        '' ::character varying as sy_aae042,
                        '' ::character varying as sy_aac031,
                        '' ::character varying as sy_aac037,
                        '' ::character varying as sy_aac130,
                        '' ::character varying as sy_aae036,
'' ::character varying as yl_aae041,
                        '' ::character varying as yl_aae042,
                        '' ::character varying as yl_aac031,
                        '' ::character varying as yl_aac037,
                        '' ::character varying as yl_aac130,
                        '' ::character varying as yl_aae036,
                        '' ::character varying as gs_aae041,
                        '' ::character varying as gs_aae042,
                        '' ::character varying as gs_aac031,
                        '' ::character varying as gs_aac037,
                        '' ::character varying as gs_aac130,
                        '' ::character varying as gs_aae036,
                        '' ::character varying as br_aae041,
                        '' ::character varying as br_aae042,
                        '' ::character varying as br_aac031,
                        '' ::character varying as br_aac037,
                        '' ::character varying as br_aac130,
                        '' ::character varying as br_aae036,
                        ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY aae041 desc) RN
                   from ac02
                  where substring(aae140 from 1 for 1) = '3') as a
         where RN = 1
        union all
        select *
          from (select aac001,
                        '' ::character varying as yb_aae041,
                        '' ::character varying as yb_aae042,
                        '' ::character varying as yb_aac031,
                        '' ::character varying as yb_aac037,
                        '' ::character varying as yb_aac130,
                        '' ::character varying as yb_aae036,
                        aae041 sy_aae041,
                        aae042 sy_aae042,
                        aac031 sy_aac031,
                        aac037 sy_aac037,
                        aac130 sy_aac130,
                        aae036 sy_aae036,
                        '' ::character varying as yl_aae041,
                        '' ::character varying as yl_aae042,
                        '' ::character varying as yl_aac031,
                        '' ::character varying as yl_aac037,
                        '' ::character varying as yl_aac130,
                        '' ::character varying as yl_aae036,
                        '' ::character varying as gs_aae041,
                        '' ::character varying as gs_aae042,
                        '' ::character varying as gs_aac031,
                        '' ::character varying as gs_aac037,
                        '' ::character varying as gs_aac130,
                        '' ::character varying as gs_aae036,
                        '' ::character varying as br_aae041,
                        '' ::character varying as br_aae042,
                        '' ::character varying as br_aac031,
                        '' ::character varying as br_aac037,
                        '' ::character varying as br_aac130,
                        '' ::character varying as br_aae036,
                        ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY aae041 desc) RN
                   from ac02
                  where substring(aae140 from 1 for 1) = '2') as a
         where RN = 1
        union all
        select *
          from (select aac001,
                        '' ::character varying as yb_aae041,
                        '' ::character varying as yb_aae042,
                        '' ::character varying as yb_aac031,
                        '' ::character varying as yb_aac037,
                        '' ::character varying as yb_aac130,
                        '' ::character varying as yb_aae036,
                        '' ::character varying as sy_aae041,
                        '' ::character varying as sy_aae042,
                        '' ::character varying as sy_aac031,
                        '' ::character varying as sy_aac037,
                        '' ::character varying as sy_aac130,
                        '' ::character varying as sy_aae036,
                        aae041 yl_aae041,
                        aae042 yl_aae042,
                        aac031 yl_aac031,
                        aac037 yl_aac037,
                        aac130 yl_aac130,
                        aae036 yb_aae036,
                        '' ::character varying as gs_aae041,
                        '' ::character varying as gs_aae042,
                        '' ::character varying as gs_aac031,
                        '' ::character varying as gs_aac037,
                        '' ::character varying as gs_aac130,
                        '' ::character varying as gs_aae036,
                        '' ::character varying as br_aae041,
                        '' ::character varying as br_aae042,
                        '' ::character varying as br_aac031,
                        '' ::character varying as br_aac037,
                        '' ::character varying as br_aac130,
                        '' ::character varying as br_aae036,
                        ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY aae041 desc) RN
                   from ac02
                  where substring(aae140 from 1 for 1) = '1') as a
         where RN = 1
        union all
        select *
          from (select aac001,
                        '' ::character varying as yb_aae041,
                        '' ::character varying as yb_aae042,
                        '' ::character varying as yb_aac031,
                        '' ::character varying as yb_aac037,
                        '' ::character varying as yb_aac130,
                        '' ::character varying as yb_aae036,
                        
                        '' ::character varying as sy_aae041,
                        '' ::character varying as sy_aae042,
                        '' ::character varying as sy_aac031,
                        '' ::character varying as sy_aac037,
                        '' ::character varying as sy_aac130,
                        '' ::character varying as sy_aae036,
                        '' ::character varying as yl_aae041,
                        '' ::character varying as yl_aae042,
                        '' ::character varying as yl_aac031,
                        '' ::character varying as yl_aac037,
                        '' ::character varying as yl_aac130,
                        '' ::character varying as yl_aae036,
                        aae041 gs_aae041,
                        aae042 gs_aae042,
                        aac031 gs_aac031,
                        aac037 gs_aac037,
                        aac130 gs_aac130,
                        aae036 gs_aae036,
                        '' ::character varying as br_aae041,
                        '' ::character varying as br_aae042,
                        '' ::character varying as br_aac031,
                        '' ::character varying as br_aac037,
                        '' ::character varying as br_aac130,
                        '' ::character varying as br_aae036,
                        ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY aae041 desc) RN
                   from ac02
                  where substring(aae140 from 1 for 1) = '4') as a
         where RN = 1
        union all
        select *
          from (select aac001,
                        '' ::character varying as yb_aae041,
                        '' ::character varying as yb_aae042,
                        '' ::character varying as yb_aac031,
                        '' ::character varying as yb_aac037,
                        '' ::character varying as yb_aac130,
                        '' ::character varying as yb_aae036,
                        '' ::character varying as sy_aae041,
                        '' ::character varying as sy_aae042,
                        '' ::character varying as sy_aac031,
                        '' ::character varying as sy_aac037,
                        '' ::character varying as sy_aac130,
                        '' ::character varying as sy_aae036,
                        
                        '' ::character varying as yl_aae041,
                        '' ::character varying as yl_aae042,
                        '' ::character varying as yl_aac031,
                        '' ::character varying as yl_aac037,
                        '' ::character varying as yl_aac130,
                        '' ::character varying as yl_aae036,
                        '' ::character varying as gs_aae041,
                        '' ::character varying as gs_aae042,
                        '' ::character varying as gs_aac031,
                        '' ::character varying as gs_aac037,
                        '' ::character varying as gs_aac130,
                        '' ::character varying as gs_aae036,
                        aae041 br_aae041,
                        aae042 br_aae042,
                        aac031 br_aac031,
                        aac037 br_aac037,
                        aac130 br_aac130,
                        aae036 br_aae036,
                        ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY aae041 desc) RN
                   from ac02
                  where substring(aae140 from 1 for 1) = '5') as a
         where RN = 1  
         ) as T 
         group by aac001;
"
 psql -d src -U sjcj -c "${v_sql}"
v_sql="          
DELETE FROM DWD.DWD_V_D_USER_AC02 ;
--WHERE yb_aae036 = '${v_date_id}';
insert into DWD.DWD_V_D_USER_AC02
select aa.aac001,
       max(case
             when '${v_date_id}' =
                  to_char(to_date(yb_aae036, 'YYYY-MM-DD'), 'YYYYMMDD') then
              '1'
             else
              '0'
           end) is_add_yb, 
       MAX(case
             when BB.AAC001 IS NULL then
              0
             else
              YB_LJ_TIME
           end) YB_LJ_TIME,
       MAX(case
             when CC.aac001 IS NULL then
              0
             else
              YB_LX_TIME
           end) YB_LX_TIME,
       max(yb_aae041) yb_aae041,
       max(yb_aae042) yb_aae042,
       max(yb_aac031) yb_aac031,
       max(yb_aac037) yb_aac037,
       max(yb_aac130) yb_aac130,
       max(YB_AAE036) YB_AAE036,
       
       max(case
             when '${v_date_id}' =
                  to_char(to_date(yl_aae036, 'YYYY-MM-DD'), 'YYYYMMDD') then
              '1'
             else
              '0'
           end) is_add_yl, 
       MAX(case
             when BB.aac001 IS NULL then
              0
             else
              YL_LJ_TIME
           end) YL_LJ_TIME,
       MAX(case
             when  CC.aac001 IS NULL then
              0
             else
              YL_LX_TIME
           end) YL_LX_TIME,
       max(yl_aae041) yl_aae041,
       max(yl_aae042) yl_aae042,
       max(yl_aac031) yl_aac031,
       max(yl_aac037) yl_aac037,
       max(yl_aac130) yl_aac130,
       max(YL_AAE036) YL_AAE036, 
       max(case
             when '${v_date_id}' =
                  to_char(to_date(sy_aae036, 'YYYY-MM-DD'), 'YYYYMMDD') then
              '1'
             else
              '0'
           end) is_add_sy, 
       MAX(case
             when BB.aac001 IS NULL then
              0
             else
              SY_LJ_TIME
           end) SY_LJ_TIME,
       MAX(case
             when CC.aac001 IS NULL then
              0
             else
              SY_LX_TIME
           end) SY_LX_TIME,
       max(sy_aae041) sy_aae041,
       max(sy_aae042) sy_aae042,
       max(sy_aac031) sy_aac031,
       max(sy_aac037) sy_aac037,
       max(sy_aac130) sy_aac130,
       max(SY_AAE036) SY_AAE036,
       max(case
             when '${v_date_id}' =
                  to_char(to_date(GS_aae036, 'YYYY-MM-DD'), 'YYYYMMDD') then
              '1'
             else
              '0'
           end) is_add_gs, 
       MAX(case
             when BB.aac001 IS NULL then
              0
             else
              GS_LJ_TIME
           end) GS_LJ_TIME,
       MAX(case
             when CC.aac001 IS NULL then
              0
             else
              GS_LX_TIME
           end) GS_LX_TIME,
       max(gs_aae041) gs_aae041,
       max(gs_aae042) gs_aae042,
       max(gs_aac031) gs_aac031,
       max(gs_aac037) gs_aac037,
       max(gs_aac130) gs_aac030,
       max(GS_AAE036) GS_AAE036,
       max(case
             when '${v_date_id}' =
                  to_char(to_date(br_aae036, 'YYYY-MM-DD'), 'YYYYMMDD') then
              '1'
             else
              '0'
           end) is_add_br, 
       MAX(case
             when BB.aac001 IS NULL then
              0
             else
              BR_LJ_TIME
           end) BR_LJ_TIME,
       MAX(case
             when CC.aac001 IS NULL then
              0
             else
              BR_LX_TIME
           end) BR_LX_TIME,
       max(br_aae041) br_aae041,
       max(br_aae042) br_aae042,
       max(br_aac031) br_aac031,
       max(br_aac037) br_aac037,
       max(br_aac130) br_aac130,
       max(BR_AAE036) BR_AAE036
  from dwd.mid_v_d_user_time    aa
       LEFT JOIN 
       dwd.mid_v_d_user_lj_time bb
           ON aa.aac001 = bb.aac001
           left join
       dwd.mid_v_d_user_lx_time cc
           ON aa.aac001 = cc.aac001
 group by aa.aac001;
"
 psql -d src -U sjcj -c "${v_sql}"
##***********************************************
##***********************************************
v_enddate=`date +'%y%m%d%h%m%s'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date_id}'
     and procname= '${v_procname}' ;"
P_DWD_V_D_USER_CB_STATUS.SH
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_USER_CB_STATUS
#  *功能描述 --%@COMMENT: 
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DWD
#  *主题-%@MASTER_FIELD: 
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:  AC02
#  *目标-%@TO: DWD.DWD_V_D_USER_CB_STATUS
#  ******************************************************************

##***************************************************************************
##***************************************************************************
  v_date_id=$1
  v_pkg=P_DWD
  v_procname=P_DWD_V_D_USER_CB_STATUS
  v_tablename=DWD.DWD_V_D_USER_CB_STATUS

##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date +'%Y%m%d%H%M%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date_id}' and procname= '${v_procname}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date_id}' and procname= '${v_procname}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date_id}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
v_sql=" truncate table  DWD.DWD_V_D_USER_CB_STATUS ;"
psql -d src -U sjcj -c "${v_sql}"
v_sql="
insert into DWD.DWD_V_D_USER_CB_STATUS
select AAC001, 
       MIN(AAC031),
           MIN(AAC037),
       MAX(AAC130),
       MAX(AAE036)
from( 
select * from (
select    AAC001,        
          AAC031,
          '999'::character varying AAC037,
          AAC130,
          AAE036,
                  ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY aae041 desc,AAC031 asc) RN
         from AC02 where AAE036 <= '${v_date_id}'
         ) as t1
         where t1.rn = 1
union all
select * from (
select    AAC001,        
          '999'::character varying AAC031,
          case when AAC037 = '' then '999' else AAC037 end  AAC037,
          AAC130,
          AAE036,
                  ROW_NUMBER() OVER(PARTITION BY aac001 ORDER BY AAE041 desc,AAC037 asc) RN
         from AC02 where AAE036 <= '${v_date_id}'
                 )       as t2
         where t2.rn = 1
         ) AS A GROUP BY AAC001;" 
psql -d src -U sjcj -c "${v_sql}"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date +'%y%m%d%h%m%s'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date_id}'
     and procname= '${v_procname}' ;"
P_DWD_V_M_USER_SB_FEE.SH
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_M_USER_SB_FEE
#  *功能描述 --%@COMMENT: 
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DWD
#  *主题-%@MASTER_FIELD: 
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM: 
#  *目标-%@TO: DWD.DWD_V_M_USER_SB_FEE
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账期(yyyymmdd)
#          现阶段固定了prov和area
##***************************************************************************
  v_date_id=$1
  v_pkg=P_DWD
  v_procname=P_DWD.DWD_V_M_USER_SB_FEE
  v_tablename=DWD.DWD_V_M_USER_SB_FEE
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************  
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date +'%Y%m%d%H%M%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date_id}' and procname= '${v_procname}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date_id}' and procname= '${v_procname}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date_id}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
v_month_id=`echo  ${v_date_id}| cut -c 1-6`
v_sql=" delete from DWD.DWD_V_M_USER_SB_FEE WHERE AAE002 = '${v_month_id}'; "
psql -d src -U sjcj -c "${v_sql}"
v_sql="     
    INSERT INTO DWD.DWD_V_M_USER_SB_FEE
     select
         'EMPI_ID' EMPI_ID,
     AAE002,
     AAB001,
     AAC001,
     AAE003,
     AAE143,
     BAB221,
     BAA063,
     AAA060,
     BAA082,
     AAC008,
     AAE140,
     BAC121,
     sum(AAC123) AAC123,
     sum(BAC125) BAC125,
     sum(BAC123) BAC123,
     sum(BAC126) BAC126,
     AAE114,
     AAB191,
     BAC202,
     AAE070,
     AAA090,
     aaf001 
   from ac13_fq where AAE002 = '${v_month_id}'
    group by 
     EMPI_ID,
     AAE002,
     AAB001,
     AAC001,
     AAE003,
     AAE143,
     BAB221,
     BAA063,
     AAA060,
     BAA082,
     AAC008,
     AAE140,
     BAC121,
     AAE114,
     AAB191,
     BAC202,
     AAE070,
     AAA090,
     aaf001;
     "
psql -d src -U sjcj -c "${v_sql}"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date +'%y%m%d%h%m%s'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date_id}'
     and procname= '${v_procname}' ;"
P_DWD_V_D_INPATIENT_DRUG_SEC.sh:
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_INPATIENT_DRUG_SEC
#  *功能描述 --%@COMMENT: 
#  *执行周期 --%@PERIOD:朿
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建亿--%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DW屿
#  *主题埿--%@MASTER_FIELD: 
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源衿--%@FROM:  
#  *目标衿--%@TO:   
#  ******************************************************************
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
##***************************************************************
##日志文件定义，确定日志文件存放的位置及日志文件名称
##命名方式为：shell名称_账期_省分_系统时间戳.log
##例如：p_dwa_v_m_cus_3g_user_info_201310_079_20131127172425.log
##规范：过程名统一小写
##***************************************************************
  v_date=$1
  v_prov="076"
  v_pkg=dwd_test
  v_procname=P_DWD_V_D_INPATIENT_DRUG_SEC
  v_tablename=DWD_V_D_INPATIENT_DRUG_SEC
##***********************************************
#判断前置依赖关系待补兿
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等徿
##***********************************************
##************************************
#固定模板，不需修改
#插入日志
v_starttime=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date}' and procname= '${v_procname}' and prov_id = '${v_prov}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date}' and procname= '${v_procname}' and prov_id = '${v_prov}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date}', '${v_pkg}', '${v_procname}', '${v_prov}', '${v_starttime}','','${v_tablename}');"
##************************************
##***********************************************
##***********************************************
psql -d src -U sjcj -c"
truncate table dwd.DWD_V_D_INPATIENT_DRUG_SEC;"
v_sql=" insert into dwd.DWD_V_D_INPATIENT_DRUG_SEC
select  '${v_date}'::character varying as date_id , 
 t.rbusiness_date          ,
t.ORG_CODE                 ,
t.INPAT_FORM_NO            ,
t.ID                       ,
t.CN_MEDICINE_TYPE_CODE    ,
t.DRUG_TYPE_CODE           ,
t.DRUG_LOCAL_CODE          ,
t.DRUG_NAME                ,
t.DRUG_FORM_CODE           ,
t.DRUG_USING_DAYS          ,
t.DRUG_USING_FREQ          ,
t.DRUG_DOSE_UNIT           ,
t.DRUG_PER_DOSE            ,
t.DRUG_TOTAL_DOSE          ,
t.DRUG_ROUTE_CODE          ,
t.DRUG_STOP_DTIME          ,
t.DRUG_STD_NAME            ,
t.DRUG_STD_CODE            ,
t.DRUG_TOTAL_UNIT          ,
t.SPEC                     ,
t.GROUP_NO                 ,
t.DRUG_START_DTIME         ,
t.DISPENSING_DTIME         ,
t.NOTES                    ,
t.DDD_VALUE                ,
t.ANTIBACTERIAL_FLAG       ,
t.CRUCIAL_DRUG_NAME        ,
t.CRUCIAL_DRUG_USAGE       ,
t.DRUG_ADVERSE_REACTION    ,
t1.patient_id                             
from 
(select a.* from SECOND_HOSPITAL.Inpatient_DRUG as a) as t
left join 
(select distinct INPAT_FORM_NO,patient_id
 from SECOND_HOSPITAL.Inpatient as a
) as t1
on t.INPAT_FORM_NO = t1.INPAT_FORM_NO;"
psql -d src -U sjcj -c"$v_sql";
##**********************************
#更新日志
#固定模板，不需修改
v_enddate=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date}'
     and procname= '${v_procname}'
     and prov_id = '${v_prov}';"
##****************************************************************
P_DWD_V_D_INPATIENT_FEE_SEC.sh
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_INPATIENT_FEE_SEC
#  *功能描述 --%@COMMENT: 
#  *执行周期 --%@PERIOD:朿
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建亿--%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DW屿
#  *主题埿--%@MASTER_FIELD: 
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源衿--%@FROM:  
#  *目标衿--%@TO:   
#  ******************************************************************
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
##***************************************************************
##日志文件定义，确定日志文件存放的位置及日志文件名称
##命名方式为：shell名称_账期_省分_系统时间戳.log
##例如：p_dwa_v_m_cus_3g_user_info_201310_079_20131127172425.log
##规范：过程名统一小写
##***************************************************************
  v_date=$1
  v_prov="076"
  v_pkg=dwd_test
  v_procname=P_DWD_V_D_INPATIENT_FEE_SEC
  v_tablename=DWD_V_D_INPATIENT_FEE_SEC
##***********************************************
#判断前置依赖关系待
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##************************************
#固定模板，不需修改
#插入日志
v_starttime=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date}' and procname= '${v_procname}' and prov_id = '${v_prov}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date}' and procname= '${v_procname}' and prov_id = '${v_prov}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date}', '${v_pkg}', '${v_procname}', '${v_prov}', '${v_starttime}','','${v_tablename}');"
##************************************
##***********************************************
#脚本使
##***********************************************
psql -d src -U sjcj -c"
truncate table dwd.DWD_V_D_INPATIENT_FEE_SEC;"
v_sql=" insert into dwd.DWD_V_D_INPATIENT_FEE_SEC
select  '${v_date}'::character varying as date_id , 
 t.rbusiness_date          ,
t.ORG_CODE                  ,
t.INPAT_FORM_NO             ,
t.ID                        ,
t.INPAT_FEE_TYPE_NAME       ,
t.INPAT_FEE_TYPE_CODE       ,
t.INPAT_FEE_AMOUNT          ,
t.PAY_WAY_CODE              ,
t.INPAT_SETTLE_WAY_CODE     ,
t.PRICE_ITEM_LOCAL_CODE     ,
t.PRICE_ITEM_LOCAL_NAME     ,
t.PRICE_ITEM_STD_CODE       ,
t.DEDUCT_FEES_DTIME         ,
t.SPEC                      ,
t.UNIT                      ,
t.PRICE                     ,
t.QUANTITY                  ,
t.NOTES                     ,
t.SELF_PAYMENT              ,
t.BABY_FLAG                 ,
t.APPLY_DEPT_CODE           ,
t.APPLY_DEPT_NAME           ,
t.APPLY_DOCTOR              ,
t.EXEC_DEPT_CODE            ,
t.EXEC_DEPT_NAME            ,
t.EXEC_MAN                  ,
t.CHARGES                   ,
t.INSURANCE_CHARGES         ,
t.DERATE_CHARGES            ,
t.OPERATOR                  ,
t.CINSUR_PERCENT            ,
t1.patient_id                        
from 
(select a.* from SECOND_HOSPITAL.Inpatient_Fee as a) as t
left join 
(select distinct INPAT_FORM_NO,patient_id
 from SECOND_HOSPITAL.Inpatient as a
) as t1
on t.INPAT_FORM_NO = t1.INPAT_FORM_NO;"
psql -d src -U sjcj -c"$v_sql";
##**********************************
#更新日志
#固定模板，不需修改
v_enddate=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date}'
     and procname= '${v_procname}'
     and prov_id = '${v_prov}';"
##****************************************************************
P_DWD_V_D_INPATIENT_INDIAG_SEC.sh
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWD_V_D_INPATIENT_INDIAG_SEC
#  *功能描述 --%@COMMENT: 
#  *执行周期 --%@PERIOD:朿
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建亿--%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DW屿
#  *主题埿--%@MASTER_FIELD: 
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源衿--%@FROM:  
#  *目标衿--%@TO:   
#  ******************************************************************
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
##***************************************************************
##日志文件定义，确定日志文件存放的位置及日志文件名称
##命名方式为：shell名称_账期_省分_系统时间戳.log
##例如：p_dwa_v_m_cus_3g_user_info_201310_079_20131127172425.log
##规范：过程名统一小写
##***************************************************************
  v_date=$1
  v_prov="076"
  v_pkg=dwd_test
  v_procname=P_DWD_V_D_INPATIENT_INDIAG_SEC
  v_tablename=DWD_V_D_INPATIENT_INDIAG_SEC
##***********************************************
#判断前置依赖关系待补兿
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等徿
##***********************************************
##************************************
#固定模板，不需修改
#插入日志
v_starttime=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c" insert into dwd.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwd.dw_execute_log t
where acct_month= '${v_date}' and procname= '${v_procname}' and prov_id = '${v_prov}';
delete  from  dwd.dw_execute_log where acct_month= '${v_date}' and procname= '${v_procname}' and prov_id = '${v_prov}';
insert into dwd.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date}', '${v_pkg}', '${v_procname}', '${v_prov}', '${v_starttime}','','${v_tablename}');"
##************************************
##***********************************************
#脚本使
##***********************************************
psql -d src -U sjcj -c"
truncate table dwd.DWD_V_D_INPATIENT_INDIAG_SEC;"
v_sql=" insert into dwd.DWD_V_D_INPATIENT_INDIAG_SEC
select  '${v_date}'::character varying as date_id , 
 t.rbusiness_date          ,
t.ORG_CODE             ,
t.DIAG_RESULT_CODE     ,
t.INPAT_FORM_NO        ,
t.DIAGNOSIS_ID         ,
t.IN_DIAG_NAME         ,
t.IN_DIAG_CODE         ,
t.CONFIRMED_DIAG_DATE  ,
t.PROPERTY_CODE        ,
t.DIAG_EXPLAN          ,
t.DIAG_TYPE_CODE       ,
t1.patient_id      ,
t2.OUT_DIAG_CODE,
t2.OUT_DIAG_NAME,
t2.TREAT_RESULT_CODE,
t2.DIAG_EXPLAN  out_DIAG_EXPLAN                         
from 
(select * from SECOND_HOSPITAL.INPATIENT_INDIAG) as t
left join 
(select distinct INPAT_FORM_NO,patient_id
 from SECOND_HOSPITAL.Inpatient as a
) as t1
on t.INPAT_FORM_NO = t1.INPAT_FORM_NO
left join
(select * from SECOND_HOSPITAL.INPATIENT_OUTDIAG) as t2
on  t.INPAT_FORM_NO = t2.INPAT_FORM_NO
and  t.DIAGNOSIS_ID = t2.DIAGNOSIS_ID
;"
psql -d src -U sjcj -c"$v_sql";
##**********************************
#更新日志
#固定模板，不需修改
v_enddate=`date '+%Y-%m-%d %H:%M:%S'`
psql -d src -U sjcj -c"update dwd.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date}'
     and procname= '${v_procname}'
     and prov_id = '${v_prov}';"
##****************************************************************
p_dm_health_location.sh
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DM_HEALTH_LOCATION
#  *功能描述 --%@COMMENT:位置信息    
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DWA
#  *主题-%@MASTER_FIELD:  
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:   
#                 #  *目标-%@TO:    #                 
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账yyymmdd)
##***************************************************************************
  v_date_id=$1
  v_pkg=DWA
  v_procname=P_DM_HEALTH_LOCATION
  v_tablename=DM_HEALTH_LOCATION
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date +'%Y%m%d%H%M%S'`
psql -d src -U sjcj -c" insert into dwa.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwa.dw_execute_log t
where acct_month= '${v_date_id}' and procname= '${v_procname}';
delete  from  dwa.dw_execute_log where acct_month= '${v_date_id}' and procname= '${v_procname}';
insert into dwa.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date_id}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
psql -d src -U sjcj -c "
truncate table DWA.DM_HEALTH_LOCATION;"
psql -d src -U sjcj -c "
insert into dwa.DM_HEALTH_LOCATION
  select tt.empi_id, tt.id_no, tt.name, '居住地', tt.AAC026
    from (select t.empi_id,
                 t.id_no,
                 t.name,
                 '居住地',
                 t1.AAC026,
                 row_number() over(partition by t.empi_id order by t1.AAC026) rm
            from (SELECT empi_table.empi_id,
                         empi_table.id_no,
                         empi_table.name
                    FROM empi_table
                   WHERE empi_table.score >= 50) t
            join (select AAC002, AAC026
                   from DWD.DWD_V_D_AC01
                  where length(AAC026) > 1) t1 ---'居住地'       
              ON btrim(t1.AAC002 ::text) = btrim(t.id_no ::text)  ) tt
   where rm = 1";
psql -d src -U sjcj -c " 
  insert into dwa.DM_HEALTH_LOCATION
  select t.empi_id,
         t.id_no,
         t.name,
         '出生地' ,
         t2.BIRTH_ADDR_PROVINCE chusheng
    from (SELECT empi_table.empi_id, empi_table.id_no, empi_table.name
            FROM empi_table
           WHERE empi_table.score >= 50) t
    join (select a.id_no, a1.BIRTH_ADDR_PROVINCE
            from DWA.DWA_V_D_INPATIENT_INDIAG_BASE a
            join (select PATIENT_ID, BIRTH_ADDR_PROVINCE
                   from dwa.dwa_v_d_Inpatient_FirstPage) a1 ---出生地
              on a.PATIENT_ID = a1.PATIENT_ID
           group by a.id_no, a1.BIRTH_ADDR_PROVINCE) t2
      ON btrim(t.id_no ::text) = btrim(t2.id_no ::text)";
psql -d src -U sjcj -c "
 insert into dwa.DM_HEALTH_LOCATION
select t.empi_id, t.id_no, t.name, '就医', case when a1.akb020 =t2.AKB020   then t2.addr_desc else '河南省开封市' end
  from (SELECT empi_table.empi_id, empi_table.id_no, empi_table.name
          FROM empi_table
         WHERE empi_table.score >= 50) t
  join (select  akb020, akc190, a.AAC002
          from DWD.DWD_V_D_KC24_KC21 aa          
          join DWD.DWD_V_D_AC01 a
            on aa.aac001 = a.aac001
            where  AKA130  in ('11','21')) a1
    on    btrim(t.id_no ::text) = btrim(a1.AAC002 ::text)
  left join (select akb020 , addr_desc
               from dwa.location_code
               where flag='1'
             ) T2
    on a1.akb020 =t2.AKB020  ";
  psql -d src -U sjcj -c "
  insert into dwa.DM_HEALTH_LOCATION
select t.empi_id, t.id_no, t.name, '购药', case when T1.drug_store =t2.AKB020    then t2.addr_desc else '河南省开封市' end
  from dwa.dwa_v_d_kc24_kc22_drug T1
  join (SELECT empi_table.empi_id, empi_table.id_no, empi_table.name
          FROM empi_table
         WHERE empi_table.score >= 50) t
    on btrim(t.id_no ::text) = btrim(t1.id_no ::text)
 left join (select akb020 , addr_desc
               from dwa.location_code
               where flag='2'
             ) T2
    on T1.drug_store =t2.AKB020 
  group by   t.empi_id, t.id_no, t.name,case when T1.drug_store =t2.AKB020    then t2.addr_desc else ' ' end";
##**********************************
#更新日志
##***********************************************
v_enddate=`date +'%y%m%d%h%m%s'`
psql -d src -U sjcj -c"update dwa.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date_id}'
     and procname= '${v_procname}' ;"      
       P_DM_HEALTH_VIEW.sh
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DM_HEALTH_VIEW_FQ
#  *功能描述 --%@COMMENT:      
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:V_MONTH 日期,格式YYYYMM
#  *参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#  *参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#  *创建-%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL:DWA
#  *主题-%@MASTER_FIELD:  
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:   
#                 #  *目标-%@TO:    #                 
#  ******************************************************************
##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账yyymmdd)
##***************************************************************************
  v_date_id=$1
  v_pkg=DWA
  v_procname=P_DM_HEALTH_VIEW_FQ
  v_tablename=DM_HEALTH_VIEW_FQ_new
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date +'%Y%m%d%H%M%S'`
psql -d src -U sjcj -c" insert into dwa.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwa.dw_execute_log t
where acct_month= '${v_date_id}' and procname= '${v_procname}';
delete  from  dwa.dw_execute_log where acct_month= '${v_date_id}' and procname= '${v_procname}';
insert into dwa.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date_id}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
psql -d src -U sjcj -c "
truncate table DWA.DM_HEALTH_VIEW_all_new;"
psql -d src -U sjcj -c "
INSERT INTO DWA.DM_HEALTH_VIEW_all_new
select 
empi_id,
id_no ,
VISIT_DTIME visit_dtime,
'门诊' pat_type,
RESP_DOCTOR_NAME doctor_name,
VISIT_DEPT_NAME,
' ' as location ,
OUTPAT_DIAG_NAME con_desc ,
'M'||OUTPAT_FORM_NO as view_id,
replace(substring(VISIT_DTIME from 1 for 10),'-','')
from dwa.dwa_v_d_Outpatient where empi_id <>'' 
union all
select 
empi_id,
id_no id_no ,
in_dtime visit_dtime, 
'住院' as pat_type, 
IN_CHARGE_DOCTOR_NAME doctor_name, 
IN_DEPT_NAME visit_dept_name,
' ' as location, 
inpat_diag_name  con_desc,
'Z'||inpat_form_no   view_id ,
replace(substring(in_dtime from 1 for 10),'-','')
from dwa.DWA_V_D_INPATIENT where empi_id <>''
union all
select 
''         empi_id ,
USER_ID  id_no, 
TO_CHAR(USE_DATE,'YYYY-MM-DD HH:MM:SS')  visit_dtime ,
'APP使用行为'  pat_type ,
''       doctor_name ,
''       visit_dept_name, 
LONGITUDE||'E,'||LATITUDE||'N'   as location ,
BOUGHT   con_desc ,
ID       view_id ,
TO_CHAR(USE_DATE,'YYYYMMDD')
from H_BEHAVIOR where USER_ID <>''
union all
select 
''  empi_id ,
USER_ID  id_no ,
 M_TIME          visit_dtime ,
'血压'   pat_type ,
''      doctor_name ,
''      visit_dept_name,
LONGITUDE||'E,'||LATITUDE||'N'  as location,
DBP||'-'||SBP    con_desc ,
ID       view_id,
replace(substring(M_TIME from 1 for 7),'-','') 
from DWD.DWD_V_D_DEVICE_XY  where USER_ID <>''
union all
select 
''  empi_id ,
USER_ID  id_no ,
M_TIME     visit_dtime ,
'血糖' pat_type, 
'' as doctor_name, 
'' as visit_dept_name,
POSITION as location, 
BG con_desc ,
ID view_id ,
replace(substring(M_TIME from 1 for 7),'-','') 
from DWD.DWD_V_D_DEVICE_XT where USER_ID <>''
;"
psql -d src -U sjcj -c "
INSERT INTO DWA.DM_HEALTH_VIEW_all_new
select 
''  empi_id,
T1.id_no  id_no,
T1.drug_time  visit_dtime,
'购药' pat_type,
T1.doctor  as doctor_name ,
'' visit_dept_name,
T2.akb021 as location,
array_to_string(ARRAY (SELECT unnest(array_agg(T1.drug_name))),'|') con_desc,
T1.AKC190||T1.AAE072 as view_id ,
replace(substring(T1.drug_time from 1 for 10),'-','')
from 
dwa.dwa_v_d_kc24_kc22_drug T1 left join (select   AKB020,akb021    from kb01 group by AKB020,akb021) T2
on t2.AKB020=t1.drug_store
group by
empi_id,
id_no,
visit_dtime,
pat_type,
doctor_name ,
visit_dept_name,
location,
view_id ,
replace(substring(T1.drug_time from 1 for 10),'-','')
union all
 SELECT empi_id empi_id, 
empi_id id_no, 
balance_date visit_date ,
'医保结算单' pat_type, 
 akc202  as doctor_name ,
akc323  dept_name ,
t2.akb021 as location ,
diag_name  con_desc, 
case when t3.mzxh <>'' then t3.OUTPAT_FORM_NO else  t1.outpat_form_no end AS  view_id ,
replace(substring(T1.agent_date from 1 for 10),'-','')
 FROM dwa.dwa_v_d_kc24_kc21_outpatient t1 left join (select akb020,akb021 from  kb01  group by akb020,akb021) t2
 on t2.akb020::text = t1.akb020::text
left join 
(select 'M'||substring(mzxh from 1 for 7) mzxh,'M'||OUTPAT_FORM_NO as OUTPAT_FORM_NO  from Outpatient_Fee 
 group by 'M'||substring(mzxh from 1 for 7) ,OUTPAT_FORM_NO ) t3
 on t1.outpat_form_no=t3.mzxh
  union all
  SELECT empi_id empi_id, 
empi_id id_no, 
balance_date visit_date ,
'医保结算单' pat_type, 
 akc202  as doctor_name ,
akc323  dept_name ,
t2.akb021 as location ,
diag_name  con_desc, 
inpat_no  view_id ,
replace(substring(T1.agent_date from 1 for 10),'-','')
 FROM dwa.dwa_v_d_kc24_kc21_inpatient t1 left join (select akb020,akb021 from  kb01  group by akb020,akb021) t2
on t2.akb020::text = t1.akb020::text
;
"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date +'%y%m%d%h%m%s'`
psql -d src -U sjcj -c"update dwa.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date_id}'
     and procname= '${v_procname}' ;"
P_DWA_V_D_THIRD_BASE.sh
#!/bin/bash
#/*@
#  ******************************************************************
#  *名称 --%@NAME: P_DWA_V_D_THIRD_BASE
#  *功能描述 --%@COMMENT:  三表合一
#  *执行周期 --%@PERIOD:
#  *参数 --%@PARAM:
#  *参数 --%@PARAM:
#  *参数 --%@PARAM:
#  *创建-%@CREATOR: 
#  *创建时间 --%@CREATED_TIME: 
#  *层次---%@LEVEL: 
#  *主题-%@MASTER_FIELD:  
#  *备注 --%@REMARK:
#  *修改记录 --%@MODIFY:
#  *来源-%@FROM:  DWA.DWA_V_D_USER_CB_BASE
#  *来源-%@FROM:  dwd.DWD_V_D_USER_BASEINFO
#  *来源-%@FROM:  h_cover
#  *目标-%@TO:    dwa.DWA_V_D_THIRD_BASE
#                 
#  ******************************************************************

##***************************************************************************
#参数说明：该shell模板调用时需传入1个参数：$1为账期(yyyymmdd)
##***************************************************************************
  v_date_id=$1
  v_pkg=DWA
  v_procname=P_DWA_V_D_THIRD_BASE
  v_tablename=dwa.DWA_V_D_THIRD_BASE
##***********************************************
#判断前置依赖关系待补
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等
##***********************************************
##***********************************************
#插入开始日
##***********************************************
#v_starttime_1=`psql -d src -U sjcj -c"select LOCALTIMESTAMP;"`
#v_starttime=`echo ${v_starttime_1} | cut -c 1-30`
v_starttime=`date +'%Y%m%d%H%M%S'`
psql -d src -U sjcj -c" insert into dwa.dw_execute_log_his
select  t.*, '${v_starttime}'   from dwa.dw_execute_log t
where acct_month= '${v_date_id}' and procname= '${v_procname}';
delete  from  dwa.dw_execute_log where acct_month= '${v_date_id}' and procname= '${v_procname}';
insert into dwa.dw_execute_log
(acct_month, pkg_name, procname, prov_id,  starttimestamp,note, table_name)
 values
('${v_date_id}', '${v_pkg}', '${v_procname}', '', '${v_starttime}','','${v_tablename}');"
##***********************************************
#脚本
##***********************************************
v_sql="
insert into dwa.DWA_V_D_THIRD_BASE
select empi_id,
       id_no,
       user_name,
       gender,
       nation,
       BIRTH_DATE,
       age,
       card_no,
       PRESENT_ADDR,
       PERMANENT_ADDR,
       tel,
       source
  from (select *,
               ROW_NUMBER() OVER(PARTITION BY id_no ORDER BY source asc) RN
          from (
                
                select  'empi_id' empi_id,
                                        AAC002 id_no,
                        AAC003 user_name,
                        case
                          when AAC004 = '1' then
                           '男'
                          when AAC004 = '2' then
                           '女'
                          else
                           '不明确'
                        end gender,
                        AAC005 nation,
                        AAC006 BIRTH_DATE,
                        age,
                        AKC020 card_no,
                        AAC026 PRESENT_ADDR,
                        AAB301 PERMANENT_ADDR,
                        AAE005 tel,
                        '1社保' source
                  from DWA.DWA_V_D_USER_CB_BASE
                
                union all
                
                select  'empi_id' empi_id,
                                        ID_NO,
                        user_name,
                        gender,
                        nation,
                        BIRTH_DATE,
                        CASE
                          when BIRTH_DATE is null then
                          when substring(BIRTH_DATE from 5 for 1) = '-' and
                               substring(BIRTH_DATE from 8 for 1) = '-' then
                           date_part('year',
                                     age(to_date('${v_date_id}', 'YYYYMMDD'),
                                         to_date(BIRTH_DATE, 'YYYYMMDD')))
                        END AGE,
                        card_no,
                        PRESENT_ADDR,
                        PERMANENT_ADDR,
                        tel,
                        source
                  from (select ID_NO,
                                NAME user_name,
                                case
                                  when SEX_CODE = '1' then
                                   '男'
                                  when SEX_CODE = '2' then
                                   '女'
                                  else
                                   '不明确'
                                end gender,
                                NATIONALITY_CODE nation,
                                BIRTH_DATE,
                                '' card_no,
                                '' PRESENT_ADDR,
                                '' PERMANENT_ADDR,
                                tel_no tel,
                                '2医院' source
                           from dwd.DWD_V_D_USER_BASEINFO) as t
                
                union all
                select  'empi_id' empi_id,
                                        id id_no, 
                        user_name, 
                        '9' gender, 
                        '' nation, 
                        '' BIRTH_DATE, 
                        0 age, 
                        '' card_no, 
                        PRESENT_ADDR, 
                        PERMANENT_ADDR, 
                        PHONE tel, 
                        '3可穿戴' source 
                  from h_cover) as A) as B
 where RN = 1;
"
psql -d src -U sjcj -c "${v_sql}"
##****************************************************************
##**********************************
#更新日志
##***********************************************
v_enddate=`date +'%y%m%d%h%m%s'`
psql -d src -U sjcj -c"update dwa.dw_execute_log
     set endtimestamp= '${v_enddate}'
   where acct_month= '${v_date_id}'
     and procname= '${v_procname}' ;"