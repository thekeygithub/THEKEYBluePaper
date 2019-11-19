1.数据采集
1.导出表结构
get_test_id()
{
  SET SERVEROUTPUT ON;
SET LINESIZE 1000;
SET FEEDBACK OFF;
set long 99999;
set pagesize 4000;
SELEct '-----', DBMS_METADATA.GET_DDL(U.OBJECT_TYPE,u.object_name) FROM  USER_OBJECTS u where U.OBJECT_TYPE IN ('TABLE','zystandard');
exit;
!
}
get_test_id>rt.log

2.导出数据
#! /bin/bash
. /etc/profile;
. ~/.bash_profile;
#file_date=`date -d '-2 day' +%Y%m%d`
file_date=$1
sys_time=`date +'%Y%m%d%H%M%S'`
sys_date=`echo $sys_time | cut -c 1-8`
file_path=/data/sjcj/wj  
clean_date=`date -d '-5 day' +%Y%m%d`
sh  ${file_path}/clean_data_shell.sh ${clean_date}
for file_id in baseinfo baseinfo_address baseinfo_allergens  baseinfo_diseasehistory baseinfo_famhistory baseinfo_payway  consultinfo eds_ce
sarean_delivery_baby  eds_cesarean_delivery_record  eds_delivery_record eds_disp_pres_master  eds_outpat_medical_record   eds_tcm_medical_re
cord  exammaster healthexam_catalog  healthexam_reg healthexam_subitem  inpatient  inpatient_consult inpatient_drug inpatient_fee  inpatient
_firstoper inpatient_firstoutdiag  inpatient_firstpage inpatient_indiag inpatient_inrecord  inpatient_longorder inpatient_outdiag inpatient_
outsummary  inpatient_proorder  inpatient_symp lab_drug_sen   lab_subitem labmaster  mid_base_resour_income_mon  mid_base_resour_org_year mi
d_base_svr_mdc_day  oper_record outpatient outpatient_diag  outpatient_drug  outpatient_fee outpatient_symp  referinfo ;
do sh wj_data.sh   ${file_id}  ${file_date} ${sys_date} M
done;
3.清理历史数据
#! /bin/bash
file_date=$1
file_path=/data/sjcj/wj/data
file_list=`ls -l ${file_path}| awk -F' ' '{print $9}'|awk -F '.' '{print $1}'`
for file_list_name in ${file_list};do
if [ ${file_list_name} -lt ${file_date} ];then
rm -rf ${file_path}/${file_list_name}
#rm  ${file_path}/${file_list_name}.tar
fi
done  
4.循环入库
#!/bin/bash
. /etc/profile
. ~/.bash_profile
file_id=$1
file_time=$2  
sys_time=$3
file_cycle=$4  
file_path=/data/sjcj/wj/data/${sys_time} 
if ! [ -e ${file_path} ];then
mkdir -p ${file_path}
fi
#file_year=`echo $2|cut -c 1-4`
#file_month=`echo $2|cut -c 5-6`
#file_day=`echo $2|cut -c 7-8`
#file_date=${file_year}-${file_month}-${file_day}     

if [ ${file_cycle} == "D" ] ; then
file_year=`echo $2 | cut -c 1-4`
file_month=`echo $2 | cut -c 5-6`
file_day=`echo $2 | cut -c 7-8`
file_date=${file_year}-${file_month}-${file_day}
elif [ ${file_cycle} == "M" ] ; then
file_year=`echo $2 | cut -c 1-4`
file_month=`echo $2 | cut -c 5-6`
file_date=${file_year}-${file_month}
elif [ ${file_cycle} == "Y" ] ; then
file_year=`echo $2 | cut -c 1-4`
file_date=${file_year}
fi
#echo   ${file_date}>>a.txt
. /data/sjcj/wj/second_level.sh  ${file_id} ${file_date}
#echo $sql_str>>a.txt
#插入日志  
start_time=`date +'%Y%m%d%H%M%S'`
psql -d src -c"delete from wj_data.log where file_id = '${file_id}' and file_cycle = '${file_cycle}' and file_date = '${file_date}';
insert into wj_data.log  (file_id, file_cycle, file_date, start_time,end_time, out_num, in_num, result) values ('${file_id}', '${file_cycle}
', '${file_date}', '${start_time}','', '',
 '', '');"
#数据抽取
sqluldr query="${sql_str}"  charset=UTF8 field="$"  safe=yes  file=/data/sjcj/wj/data/${sys_time}/${file_id}_${file_time}.txt 2>&1 | tee -a /data/sjcj/wj/log/${sys_time}_out.log > /dev/null      
sed -i 's#\/#\-#g;s#\\#\-#g' /data/sjcj/wj/data/${sys_time}/${file_id}_${file_time}.txt
#数据量
out_num=`cat /data/sjcj/wj/log/${sys_time}_out.log | tail -1 | awk '{print $6}'`       
#echo ${out_num}>>2.txt
  #数据清空
psql -d src -c"${delete_sql} ">&1 | tee -a /data/sjcj/wj/log/${sys_time}_in.log > /dev/null      ;
#echo $delete_sql>>1.txt    
#数据录入
psql -d src -c"\copy wj_data.${file_id} from '/data/sjcj/wj/data/${sys_time}/${file_id}_${file_time}.txt' delimiter '$' " >&1 | tee -a /data
/sjcj/wj/log/${sys_time}_in2.log > /dev/null ;         
select_num=`psql -d src -c"${select_sql};"`
in_num=`echo ${select_num} | awk '{print $3}'`
echo $select_num
echo $in_num
#结束时间
end_time=`date +'%Y%m%d%H%M%S'` 
#导入数据
select_num=`psql -d src -U sjcj -c"${select_sql};"`
in_num=`echo ${select_num} | awk '{print $3}'`
if [ "$out_num" == "$in_num" ];then
result=success
else
result=fail
fi
#更新日
 psql -d src -c"update wj_data.log set end_time='${end_time}',out_num='${out_num}' ,in_num='${in_num}' , result='${result}' where   file_id=
'${file_id}' and file_cycle='${file_cycle}' and file_date='${file_date}';"
6.字段转换
file_id=$1
file_date=$2
case ${file_id} in
 baseinfo)
sql_str="
select 
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) LAST_UPDATE_DTIME,
trim(translate(replace(ID_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ID_TYPE_CODE,
trim(translate(replace(ID_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ID_NO,
trim(translate(replace(EMPLOYER_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EMPLOYER_NAME,
trim(translate(replace(TEL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TEL_NO,
trim(translate(replace(CONTACT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONTACT_NAME,
trim(translate(replace(CONTACT_TEL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONTACT_TEL_NO,
trim(translate(replace(RESIDENCE_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) RESIDENCE_MARK,
trim(translate(replace(NATIONALITY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) NATIONALITY_CODE,
trim(translate(replace(ABO_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ABO_CODE,
trim(translate(replace(RH_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) RH_CODE,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORG_CODE,
trim(translate(replace(EDUCATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EDUCATION_CODE,
trim(translate(replace(OCCUPATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OCCUPATION_CODE,
trim(translate(replace(MARRIAGE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) MARRIAGE_CODE,
trim(translate(replace(DRUG_ALLERGY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DRUG_ALLERGY_MARK,
trim(translate(replace(OP_HISTORY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OP_HISTORY_MARK,
trim(translate(replace(TRAUMA_HISTORY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TRAUMA_HISTORY_MARK,
trim(translate(replace(BLOOD_TRANSF_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BLOOD_TRANSF_MARK,
trim(translate(replace(DISABILITY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DISABILITY_MARK,
trim(translate(replace(GENETIC_DISEASE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) GENETIC_DISEASE_HISTORY,
trim(translate(replace(EXHAUST_FACILITY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXHAUST_FACILITY_MARK,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PATIENT_ID,
trim(translate(replace(EXHAUST_FACILITY_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXHAUST_FACILITY_TYPE_CODE,
trim(translate(replace(FUEL_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) FUEL_TYPE_CODE,
trim(translate(replace(WATER_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) WATER_TYPE_CODE,
trim(translate(replace(TOILET_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TOILET_TYPE_CODE,
trim(translate(replace(LIVESTOCK_PEN_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) LIVESTOCK_PEN_TYPE_CODE,
trim(translate(replace(OPERATION_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OPERATION_HISTORY,
trim(translate(replace(CARD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CARD_NO,
trim(translate(replace(CARD_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CARD_TYPE_CODE,
trim(translate(replace(HEALTH_RECORD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) HEALTH_RECORD_NO,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BIRTH_DATE,
trim(translate(replace(DIABETES_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DIABETES_MARK,
trim(translate(replace(GLAUCOMA_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) GLAUCOMA_MARK,
trim(translate(replace(DIALYSIS_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DIALYSIS_MARK,
trim(translate(replace(CARDIOVASCULAR_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CARDIOVASCULAR_CODE,
trim(translate(replace(EPILEPSY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EPILEPSY_MARK,
trim(translate(replace(COAGULOPATHY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) COAGULOPATHY_MARK,
trim(translate(replace(CARDIAC_PAC_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CARDIAC_PAC_MARK,
trim(translate(replace(ORTHER_MEDICAL_ALERT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORTHER_MEDICAL_ALERT,
trim(translate(replace(PSYCHIATRIC_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PSYCHIATRIC_MARK,
trim(translate(replace(ORGAN_TRANS_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORGAN_TRANS_MARK,
trim(translate(replace(ORGAN_DEFECT_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORGAN_DEFECT_MARK,
trim(translate(replace(REMOVA_PRO_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) REMOVA_PRO_MARK,
trim(translate(replace(HEDRT_DIS_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) HEDRT_DIS_MARK,
trim(translate(replace(SEC_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SEC_TYPE_CODE,
trim(translate(replace(EHR_CREATE_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EHR_CREATE_DATE,
trim(translate(replace(CREATE_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CREATE_OPERATOR,
trim(translate(replace(CREATE_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CREATE_TIME,
trim(translate(replace(EMPLOYER_TEL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EMPLOYER_TEL_NO,
trim(translate(replace(CONTACT_RELATIONSHIP,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONTACT_RELATIONSHIP,
trim(translate(replace(COOPERATIVE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) COOPERATIVE_NO,
trim(translate(replace(ASTHMA_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ASTHMA_MARK,
trim(translate(replace(CARD_END_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CARD_END_DATE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ZOE_SYS_COLLECT_TIME from baseinfO  where LAST_UPDATE_DTIME  like '${file_date}%' "
delete_sql="
delete from  wj_data.baseinfO  where LAST_UPDATE_DTIME  like '${file_date}%'"    
select_sql="
 select count(1)
  from wj_data.baseinfO
 where LAST_UPDATE_DTIME  like '${file_date}%'";;


baseinfo_address)      
sql_str="select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(ADDRESS_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDRESS_TYPE_CODE,
trim(translate(replace(ADDR_PROVINCE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_PROVINCE,
trim(translate(replace(ADDR_CITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_CITY,
trim(translate(replace(ADDR_COUNTY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_COUNTY,
trim(translate(replace(ADDR_TOWN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_TOWN,
trim(translate(replace(ADDR_VILLAGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_VILLAGE,
trim(translate(replace(ADDR_HOUSE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_HOUSE_NO,
trim(translate(replace(POSTAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))POSTAL_CODE  from baseinfo_address where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.baseinfo_address where LAST_UPDATE_DTIME  like '${file_date}%'" 
select_sql="
 select count(1)
  from wj_data.baseinfo_address
 where LAST_UPDATE_DTIME  like '${file_date}%' ";; 

baseinfo_allergens)
sql_str="select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(DRUG_ALLERGENS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_ALLERGENS_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from baseinfo_allergens  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.baseinfo_allergens   where LAST_UPDATE_DTIME  like '${file_date}%'" 
select_sql="
 select count(1)
  from wj_data.baseinfo_allergens
 where LAST_UPDATE_DTIME  like '${file_date}%'";; 



baseinfo_diseasehistory) 
sql_str="select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,  
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(PAST_SICKNESS_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAST_SICKNESS_TYPE_CODE,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(PAST_SICKNESS_CONFIRM_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAST_SICKNESS_CONFIRM_DATE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from baseinfo_diseasehistory  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.baseinfo_diseasehistory  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.baseinfo_diseasehistory
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

baseinfo_famhistory)  
sql_str="select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,  
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(FAMILY_DISEASE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FAMILY_DISEASE_CODE,
trim(translate(replace(PATIENT_RELATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_RELATION_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from baseinfo_famhistory  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.baseinfo_famhistory  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.baseinfo_famhistory
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

baseinfo_payway)   
sql_str="select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,  
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(PAY_WAY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAY_WAY_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from baseinfo_payway  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.baseinfo_payway  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.baseinfo_payway
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

consultinfo)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,  
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(HEALTH_RECORD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_RECORD_NO ,
trim(translate(replace(CONSULT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_FORM_NO,  
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NAME,
trim(translate(replace(CONSULT_REASON,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONSULT_REASON,
trim(translate(replace(CONSULT_ADVICE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_ADVICE,     
trim(translate(replace(CONSULT_ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_ORG_CODE,
trim(translate(replace(CONSULT_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONSULT_ORG_NAME,
trim(translate(replace(CONSULT_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_DOCTOR_NAME,     
trim(translate(replace(RESP_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESP_DOCTOR_NAME,
trim(translate(replace(CONSULT_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONSULT_DATE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,    
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from consultinfo  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.consultinfo  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.consultinfo
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

eds_cesarean_delivery_baby)       
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(CASE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CASE_NO,
trim(translate(replace(IN_HOSPITAL_TIMES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_HOSPITAL_TIMES,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(FETUS_POSITION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FETUS_POSITION_CODE,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(BIRTH_WEIGHT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_WEIGHT,
trim(translate(replace(BIRTH_LENGTH,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_LENGTH,
trim(translate(replace(APGAR_SCORE_INTERVAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APGAR_SCORE_INTERVAL_CODE,
trim(translate(replace(APGAR_SCORE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APGAR_SCORE,
trim(translate(replace(DELIVERY_OUTCOME_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DELIVERY_OUTCOME_CODE,
trim(translate(replace(NEWBORN_ABNORMAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NEWBORN_ABNORMAL_CODE from eds_cesarean_delivery_baby  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.eds_cesarean_delivery_baby  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.eds_cesarean_delivery_baby
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

eds_cesarean_delivery_record)     
sql_str="
select
last_update_dtime           ,
 id                         ,
 org_code                   ,
 patient_id                 ,
 case_no                    ,
 in_hospital_times          ,
 inpat_form_no              ,
 name                       ,
 age_year                   ,
 dept_code                  ,
 dept_name                  ,
 ward_name                  ,
 dept_room                  ,
 bed_no                     ,
 delivery_time              ,
 full_membrane_state        ,
 chorda_umbilicalis_length  ,
 raogeng_body               ,
 prenatal_diag_name         ,
 operation_indication       ,
 operation_code             ,
 operation_name             ,
 operation_start_time       ,
 anesthesia_code            ,
 anes_position              ,
 anes_effective             ,
 operation_describe         ,
 uterus_state               ,
 delivery_baby_method       ,
 placenta_yellow            ,
 membrane_yellow            ,
 cord_entanglement_state    ,
 umbilical_cord_torsion     ,
 save_cord_blood_flag       ,
 uterine_suture_state       ,
 uterotonic_name            ,
 uterotonic_use_way         ,
 operation_drug             ,
 operation_drug_amount      ,
 exploration_uterus         ,
 exploration_adnexa         ,
 uterotonic_yc_flag         ,
 uterotonic_jl_flag         ,
 uterine_probe              ,
 operation_maternal_state   ,
 lossblood_amount           ,
 transfusion_component      ,
 transfusion_amount         ,
 infusion_amount            ,
 oxygen_time                ,
 other_drug                 ,
 other_state                ,
 operation_end_time         ,
 operation_whole_time       ,
 parturition_diagnosis      ,
 postpartum_obs_time        ,
 postpartum_exam_tim        ,
 sbp                        ,
 dbp                        ,
 pulses                     ,
 postpartum_heart_rate      ,
 postpartum_lossblood_amount,
 postpartum_uc              ,
 postpartum_fundus_height   ,
 tumor_size                 ,
 tumor_part                 ,
 operator_signature         ,
 anesthesiologist_name      ,
 device_nurse_signature     ,
 assistant_signature        ,
 baby_care_siganture        ,
 instructor_signature       ,
 writor_signature           ,
 notes                      
from eds_cesarean_delivery_record   where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.eds_cesarean_delivery_record   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.eds_cesarean_delivery_record
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

eds_delivery_record)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) LAST_UPDATE_DTIME,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(CASE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CASE_NO,
trim(translate(replace(IN_HOSPITAL_TIMES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_HOSPITAL_TIMES,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NAME,
trim(translate(replace(AGE_YEAR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AGE_YEAR,
trim(translate(replace(DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_NAME,
trim(translate(replace(WARD_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))WARD_NAME,
trim(translate(replace(DEPT_ROOM,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_ROOM,
trim(translate(replace(BED_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BED_NO,
trim(translate(replace(DELIVERY_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DELIVERY_TIME,
trim(translate(replace(GRAVIDITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))GRAVIDITY,
trim(translate(replace(PARITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PARITY,
trim(translate(replace(MENSES_LAST_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MENSES_LAST_DATE,
trim(translate(replace(CONCEPTION_FORM_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONCEPTION_FORM_CODE,
trim(translate(replace(EXPECTED_CHILDBIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXPECTED_CHILDBIRTH_DATE,
trim(translate(replace(PREGNANCY_EXAMINE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PREGNANCY_EXAMINE,
trim(translate(replace(ANTENATAL_EXAM_ABNORMAL,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ANTENATAL_EXAM_ABNORMAL,
trim(translate(replace(PREPREGNANCY_WEIGHT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PREPREGNANCY_WEIGHT,
trim(translate(replace(PRENATAL_HEIGHT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRENATAL_HEIGHT,
trim(translate(replace(PRENATAL_WEIGHT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRENATAL_WEIGHT,
trim(translate(replace(SPEC_PREGNANCY_CASE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPEC_PREGNANCY_CASE,
trim(translate(replace(DISEASE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DISEASE_HISTORY,
trim(translate(replace(OPERATION_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OPERATION_HISTORY,
trim(translate(replace(MATERNAL_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) MATERNAL_HISTORY,
trim(translate(replace(SBP,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SBP,
trim(translate(replace(DBP,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DBP,
trim(translate(replace(BODY_TEMPERATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BODY_TEMPERATURE,
trim(translate(replace(PULSES,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PULSES,
trim(translate(replace(BREATHING_RATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BREATHING_RATE,
trim(translate(replace(UTERUS_HEIGHT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) UTERUS_HEIGHT,
trim(translate(replace(ABDOMINAL_GIRTH,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ABDOMINAL_GIRTH,
trim(translate(replace(FETUS_POSITION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) FETUS_POSITION_CODE,
trim(translate(replace(FETAL_HEART_RATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) FETAL_HEART_RATE,
trim(translate(replace(HEAD_DIFFER_SITUATION_EVA,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) HEAD_DIFFER_SITUATION_EVA,
trim(translate(replace(TRANSVERSE_OUTLET,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TRANSVERSE_OUTLET,
trim(translate(replace(EXTERNAL_CONJUGATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXTERNAL_CONJUGATE,
trim(translate(replace(BIISCHIAL_DIAMETER,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BIISCHIAL_DIAMETER,
trim(translate(replace(CONTRACTION_STATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONTRACTION_STATE,
trim(translate(replace(CERVICAL_THICKNESS,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CERVICAL_THICKNESS,
trim(translate(replace(PALACE_MOUTH_STATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PALACE_MOUTH_STATE,
trim(translate(replace(MEMBRANE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) MEMBRANE_CODE,
trim(translate(replace(RUPTURE_WAY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) RUPTURE_WAY_CODE,
trim(translate(replace(PRE_PART_STATION,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRE_PART_STATION,
trim(translate(replace(AMNIOTIC_FLUID_STATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AMNIOTIC_FLUID_STATE,
trim(translate(replace(FILLING_BLADDER_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) FILLING_BLADDER_FLAG,
trim(translate(replace(INTESTINAL_INFLATION_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) INTESTINAL_INFLATION_FLAG,
trim(translate(replace(EXAM_METHOD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_METHOD_CODE,
trim(translate(replace(TREATMENT_PLAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TREATMENT_PLAN,
trim(translate(replace(PLAN_DELIVERY_METHOD,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PLAN_DELIVERY_METHOD,
trim(translate(replace(LABOR_RECORD_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) LABOR_RECORD_TIME,
trim(translate(replace(LABOR_COURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) LABOR_COURSE,
trim(translate(replace(LABOR_INSPECTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) LABOR_INSPECTOR,
trim(translate(replace(WRITOR_SIGNATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) WRITOR_SIGNATURE ,
notes from   eds_delivery_record   where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data. eds_delivery_record   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data. eds_delivery_record
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

eds_disp_pres_master) 
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORG_CODE,
trim(translate(replace(PRESCRIBE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRESCRIBE_NO,
trim(translate(replace(PRES_CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRES_CLASS_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PATIENT_ID,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OUTPAT_FORM_NO,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SEX_CODE,
trim(translate(replace(AGE_YEAR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AGE_YEAR,
trim(translate(replace(AGE_MONTH,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AGE_MONTH,
trim(translate(replace(DIAGNOSIS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DIAGNOSIS_CODE,
trim(translate(replace(DIAGNOSIS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DIAGNOSIS_NAME,
trim(translate(replace(TCM_DIAGNOSIS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TCM_DIAGNOSIS_CODE,
trim(translate(replace(TCM_SYNDROME_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TCM_SYNDROME_CODE,
trim(translate(replace(THERAPEUTIC_PRINCIPLES,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) THERAPEUTIC_PRINCIPLES,
trim(translate(replace(PRES_DESCRIBE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRES_DESCRIBE,
trim(translate(replace(TCM_DECOC_PIECE_METHOD,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TCM_DECOC_PIECE_METHOD,
trim(translate(replace(TCM_USE_METHOD,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TCM_USE_METHOD,
trim(translate(replace(COST,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) COST,
trim(translate(replace(TERM_COUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) TERM_COUNT,
trim(translate(replace(APPLY_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) APPLY_DEPT_CODE,
trim(translate(replace(APPLY_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) APPLY_TIME,
trim(translate(replace(APPLY_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) APPLY_OPERATOR,
trim(translate(replace(PERFORM_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORM_OPERATOR,
trim(translate(replace(PERFORM_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORM_DEPT_CODE,
trim(translate(replace(PERFORM_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORM_DTIME,
trim(translate(replace(AUDIT_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUDIT_OPERATOR,
trim(translate(replace(AUDIT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUDIT_TIME,
trim(translate(replace(DISTRIBUTE_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DISTRIBUTE_OPERATOR,
trim(translate(replace(CHECK_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CHECK_OPERATOR, 
trim(translate(replace(DISPENSE_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DISPENSE_OPERATOR  from  eds_disp_pres_master   
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="
delete from  wj_data.eds_disp_pres_master   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.eds_disp_pres_master
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

eds_outpat_medical_record)        
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_CODE,
trim(translate(replace(DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_NAME,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_DATE,
trim(translate(replace(AGE_YEAR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AGE_YEAR,
trim(translate(replace(AGE_MONTH,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AGE_MONTH,
trim(translate(replace(ALLERGY_HISTORY_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ALLERGY_HISTORY_FLAG,
trim(translate(replace(ALLERGY_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ALLERGY_HISTORY,
trim(translate(replace(VISIT_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_DTIME,
trim(translate(replace(FIRST_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FIRST_FLAG,
trim(translate(replace(CHIEF_COMPLAINTS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHIEF_COMPLAINTS,
trim(translate(replace(CURRENT_DISEASE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CURRENT_DISEASE,
trim(translate(replace(DISEASE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISEASE_HISTORY,
trim(translate(replace(PHYSICAL_EXAMINATION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PHYSICAL_EXAMINATION,
trim(translate(replace(TCM_OBSERVE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TCM_OBSERVE,
trim(translate(replace(ASSIST_EXAM_ITEM,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSIST_EXAM_ITEM,
trim(translate(replace(ASSIST_EXAM_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSIST_EXAM_RESULT,
trim(translate(replace(DIALECTICAL_BASIS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIALECTICAL_BASIS,
trim(translate(replace(THERAPEUTIC_PRINCIPLES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))THERAPEUTIC_PRINCIPLES,
trim(translate(replace(DOCTOR_SIGNATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DOCTOR_SIGNATURE,
trim(translate(replace(NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NOTES  from  eds_outpat_medical_record  
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.eds_outpat_medical_record   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.eds_outpat_medical_record
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

eds_tcm_medical_record)  
sql_str="
select
 last_update_dtime          ,
 org_code                   ,
 pay_way_code               ,
 card_no                    ,
 patient_id                 ,
 case_no                    ,
 in_hospital_times          ,
 inpat_form_no              ,
 report_form_no             ,
 name                       ,
 sex_code                   ,
 birth_date                 ,
 age_year                   ,
 age_month                  ,
 country_code               ,
 birth_weight               ,
 in_weight                  ,
 birth_addr_province        ,
 birth_addr_city            ,
 birth_addr_county          ,
 native_province            ,
 native_city                ,
 nationality_code           ,
 id_type_code               ,
 id_no                      ,
 occupation_code            ,
 marriage_code              ,
 addr_province              ,
 addr_city                  ,
 addr_county                ,
 addr_town                  ,
 addr_village               ,
 addr_house_no              ,
 tel_no                     ,
 present_addr_postal_code   ,
 register_addr_province     ,
 register_addr_city         ,
 register_addr_county       ,
 register_addr_town         ,
 register_addr_village      ,
 register_addr_house_no     ,
 register_addr_postal_code  ,
 employer_name              ,
 employer_addr_province     ,
 employer_addr_city         ,
 employer_addr_county       ,
 employer_addr_town         ,
 employer_addr_village      ,
 employer_addr_house_no     ,
 employer_tel_no            ,
 employer_postal_code       ,
 contact_name               ,
 contact_relationship_cd    ,
 contact_province           ,
 contact_city               ,
 contact_county             ,
 contact_village            ,
 contact_countryside        ,
 contact_door               ,
 contact_tel                ,
 in_path_code               ,
 inpat_type_code            ,
 in_dtime                   ,
 in_dept_code               ,
 in_dept_name               ,
 in_dept_room               ,
 move_dept_code             ,
 move_dept_name             ,
 discharge_dtime            ,
 out_dept_code              ,
 out_dept_name              ,
 out_dept_room              ,
 actual_in_days             ,
 clinical_pathway_code      ,
 tcm_medical_org_flag       ,
 tcm_diag_treat_device_flag ,
 tcm_diag_treat_tech_flag   ,
 syndrome_nursing_flag      ,
 damage_poison_reason       ,
 damage_poison_icd_cd       ,
 pathological_no            ,
 drug_allergy_mark          ,
 drug_allergens_name        ,
 autopsy_mark               ,
 abo_code                   ,
 rh_code                    ,
 dept_director_name         ,
 chief_doctor_name          ,
 in_charge_doctor_name      ,
 resident_doctor_name       ,
 resp_nurse_name            ,
 learning_doctor_name       ,
 intern_doctor_name         ,
 cataloger_name             ,
 case_quality_cd            ,
 qc_doctor_name             ,
 qc_nurse_name              ,
 qc_dtime                   ,
 discharge_class_cd         ,
 order_referral_org         ,
 rehosp_after31_mark        ,
 rehosp_after31_purpose     ,
 crani_befin_coma_days      ,
 crani_befin_coma_hours     ,
 crani_befin_coma_minutes   ,
 crani_behin_coma_days      ,
 crani_behin_coma_hours     ,
 crani_behin_coma_minutes   ,
 fee_total                  ,
 fee_self_pay               ,
 fee_general_medical        ,
 fee_general_tcm_treatment  ,
 fee_general_tcm_consult    ,
 fee_general_treatment      ,
 fee_nursing                ,
 fee_other_medical          ,
 fee_pathology              ,
 fee_laboratory             ,
 fee_image                  ,
 fee_clinic                 ,
 fee_nonsurgical            ,
 fee_nonsurgical_phys       ,
 fee_surgical               ,
 fee_anes                   ,
 fee_operation              ,
 fee_recovery               ,
 fee_tcm_diag               ,
 fee_tcm_treatment          ,
 fee_tcm_foreign_rule       ,
 fee_tcm_orthopedics        ,
 fee_tcm_acu_moxi           ,
 fee_tcm_massage            ,
 fee_tcm_anorectal          ,
 fee_tcm_special            ,
 fee_tcm_other              ,
 fee_tcm_special_mix        ,
 fee_tcm_drug_food          ,
 fee_west_medicine          ,
 fee_west_anti              ,
 fee_tcm_medicine           ,
 fee_tcm_org_medicine       ,
 fee_tcm_herbal_medicine    ,
 fee_blood                  ,
 fee_albumin                ,
 fee_globulin               ,
 fee_bcf                    ,
 fee_cytokine               ,
 fee_exam_material          ,
 fee_treat_material         ,
 fee_op_material            ,
 fee_other                  ,
 notes                      
from eds_tcm_medical_record  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.eds_tcm_medical_record   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.eds_tcm_medical_record
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

exammaster)   
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORG_CODE,
trim(translate(replace(REPORT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) REPORT_FORM_NO,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PATIENT_ID,
trim(translate(replace(EVENT_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EVENT_TYPE,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EVENT_NO,
trim(translate(replace(RETRIEVE_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) RETRIEVE_DATE,
trim(translate(replace(CLASS_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CLASS_TYPE_CODE,
trim(translate(replace(EXAM_SITE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_SITE_CODE,
trim(translate(replace(EXAM_ITEM_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_ITEM_CODE,
trim(translate(replace(REPORT_TITLE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) REPORT_TITLE,
trim(translate(replace(EFFECTIVE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EFFECTIVE_DTIME,
trim(translate(replace(CONFIDENTIALITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONFIDENTIALITY,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BIRTH_DATE,
trim(translate(replace(AUTHOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUTHOR_ID,
trim(translate(replace(REPORT_CREATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) REPORT_CREATE_DTIME,
trim(translate(replace(AUTHOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUTHOR_NAME,
trim(translate(replace(AUTHENTICATOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUTHENTICATOR_ID,
trim(translate(replace(AUTHENTICATOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUTHENTICATOR_DTIME,
trim(translate(replace(AUTHENTICATOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) AUTHENTICATOR_NAME,
trim(translate(replace(PARTICIPANT_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PARTICIPANT_DEPT,
trim(translate(replace(PARTICIPANT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PARTICIPANT_ID,
trim(translate(replace(PARTICIPANT_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PARTICIPANT_DTIME,
trim(translate(replace(PARTICIPANT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PARTICIPANT_NAME,
trim(translate(replace(ORDER_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORDER_ID,
trim(translate(replace(ORDER_PRIORITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORDER_PRIORITY,
trim(translate(replace(PERFORMER_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORMER_DEPT_NAME,
trim(translate(replace(PERFORMER_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORMER_DOCTOR,
trim(translate(replace(EXAM_PERFORMER_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_PERFORMER_DTIME,
trim(translate(replace(OUTPAT_DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OUTPAT_DIAG_NAME,
trim(translate(replace(PATIENT_CONDITION_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PATIENT_CONDITION_DESCR,
trim(translate(replace(EXAM_PURPOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_PURPOSE,
trim(translate(replace(IMAGE_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) IMAGE_DESCR,
trim(translate(replace(IS_ABNORMAL,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) IS_ABNORMAL,
trim(translate(replace(CONCLUSION,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CONCLUSION,
trim(translate(replace(RECOGNITION,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) RECOGNITION,
trim(translate(replace(CLASS_TYPE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CLASS_TYPE_NAME,
trim(translate(replace(EXAM_ITEM_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_ITEM_NAME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ZOE_SYS_COLLECT_TIME,
trim(translate(replace(EXAM_RESULT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_RESULT_CODE,
trim(translate(replace(EXAM_QUANTITIVE_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_QUANTITIVE_RESULT,
trim(translate(replace(QUANTITIVE_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) QUANTITIVE_UNIT,
trim(translate(replace(SPECIAL_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIAL_FLAG,
trim(translate(replace(INTERVENTION,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) INTERVENTION,
trim(translate(replace(OPERATION_WAY_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OPERATION_WAY_DESCR,
trim(translate(replace(OPERATION_COUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) OPERATION_COUNT,
trim(translate(replace(ANESTHESIA_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ANESTHESIA_CODE,
trim(translate(replace(ANESTHETIC_OBSERVATION,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ANESTHETIC_OBSERVATION,
trim(translate(replace(ANESTHETIC_CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ANESTHETIC_CLASS_CODE,
trim(translate(replace(ANESTHETIC_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ANESTHETIC_DOCTOR,
trim(translate(replace(SPECIMEN_CLASS,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIMEN_CLASS,
trim(translate(replace(SPECIMEN_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIMEN_NO,
trim(translate(replace(SPECIMEN_STATUS,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIMEN_STATUS,
trim(translate(replace(SPECIMEN_FIXATIVE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIMEN_FIXATIVE,
trim(translate(replace(SPECIMEN_SAMPLE_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIMEN_SAMPLE_TIME,
trim(translate(replace(SPECIMEN_RECEIVE_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SPECIMEN_RECEIVE_TIME,
trim(translate(replace(EXAM_TECHNICIAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_TECHNICIAN,
trim(translate(replace(DIAG_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DIAG_DATE,
trim(translate(replace(CHIEF_COMPLAINTS,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CHIEF_COMPLAINTS,
trim(translate(replace(SYMPTOM_START_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SYMPTOM_START_TIME,
trim(translate(replace(SYMPTOM_END_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SYMPTOM_END_TIME,
trim(translate(replace(BARCODE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) BARCODE_NO,
trim(translate(replace(EXAM_DEVICE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_DEVICE,
trim(translate(replace(EXAM_DEVICE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EXAM_DEVICE_NAME,
trim(translate(replace(REGISTER_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) REGISTER_TIME,
trim(translate(replace(REGISTER_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) REGISTER_OPERATOR,
trim(translate(replace(DIAGNOSE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) DIAGNOSE_CODE,
trim(translate(replace(PRINT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRINT_TIME,
trim(translate(replace(PRINT_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PRINT_OPERATOR   from   exammaster   
  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.exammaster  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.exammaster 
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

healthexam_catalog)
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ORG_CODE,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) EVENT_NO,
trim(translate(replace(HEALTH_EXAM_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) HEALTH_EXAM_FORM_NO,
trim(translate(replace(CATALOG_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CATALOG_ID,
trim(translate(replace(PERFORMER_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORMER_DEPT_NAME,
trim(translate(replace(PERFORMER_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORMER_DOCTOR,
trim(translate(replace(PERFORM_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) PERFORM_DTIME,
trim(translate(replace(SUMMARY,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) SUMMARY,
trim(translate(replace(CATALOG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) CATALOG_NAME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',',')) ZOE_SYS_COLLECT_TIME from healthexam_catalog
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.healthexam_catalog  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.healthexam_catalog 
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

healthexam_reg)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_NO,
trim(translate(replace(HEALTH_EXAM_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_EXAM_FORM_NO,
trim(translate(replace(HEALTH_RECORD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_RECORD_NO,
trim(translate(replace(CARD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CARD_NO,
trim(translate(replace(START_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))START_DTIME,
trim(translate(replace(EXAM_END_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXAM_END_DATE,
trim(translate(replace(RETRIEVE_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RETRIEVE_DATE,
trim(translate(replace(TOTAL_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TOTAL_FEE,
trim(translate(replace(ICD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ICD_CODE,
trim(translate(replace(DIAGNOSIS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_NAME,
trim(translate(replace(REPORT_TITLE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_TITLE,
trim(translate(replace(EFFECTIVE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EFFECTIVE_DTIME,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_DATE,
trim(translate(replace(AGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AGE,
trim(translate(replace(ADDRESS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDRESS,
trim(translate(replace(EMPLOYER_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EMPLOYER_NAME,
trim(translate(replace(ID_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID_NO,
trim(translate(replace(OCCUPATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OCCUPATION_CODE,
trim(translate(replace(MARRIAGE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MARRIAGE_CODE,
trim(translate(replace(EXAM_SUMMARY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXAM_SUMMARY,
trim(translate(replace(EXAM_CHIEF_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXAM_CHIEF_DOCTOR,
trim(translate(replace(HEALTH_GUIDE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_GUIDE,
trim(translate(replace(NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NOTES,
trim(translate(replace(DIAG_EXPLAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_EXPLAN,
trim(translate(replace(FOOD_GUIDANCE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FOOD_GUIDANCE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(CHECK_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHECK_TIME,
trim(translate(replace(PRINT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRINT_TIME,
trim(translate(replace(SUMMARIZE_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SUMMARIZE_TIME,
trim(translate(replace(CHECK_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHECK_DOCTOR     from  healthexam_reg  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.healthexam_reg  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.healthexam_reg
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

healthexam_subitem)
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(HEALTH_EXAM_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_EXAM_FORM_NO,
trim(translate(replace(CATALOG_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CATALOG_ID,
trim(translate(replace(SERIAL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SERIAL_NO,
trim(translate(replace(CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CLASS_CODE,
trim(translate(replace(RESULT_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_TYPE,
trim(translate(replace(RESULT_TYPE_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_TYPE_DESCR,
trim(translate(replace(RESULT_VALUE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_VALUE,
trim(translate(replace(RESULT_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_UNIT,
trim(translate(replace(NORM_LOWER_LIMIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NORM_LOWER_LIMIT,
trim(translate(replace(NORM_UPPER_LIMIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NORM_UPPER_LIMIT,
trim(translate(replace(NORM_VALUE_NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NORM_VALUE_NOTES,
trim(translate(replace(RESULT_INTERPRE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_INTERPRE,
trim(translate(replace(EFFECTIVE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EFFECTIVE_DTIME,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_NO,
trim(translate(replace(RESULT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_CODE,
trim(translate(replace(CLASS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CLASS_NAME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME  from healthexam_subitem   where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.healthexam_subitem   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.healthexam_subitem
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(CASE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CASE_NO,
trim(translate(replace(IN_HOSPITAL_TIMES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_HOSPITAL_TIMES,
trim(translate(replace(IN_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DEPT_NAME,
trim(translate(replace(IN_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DTIME,
trim(translate(replace(IN_REASON_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_REASON_CODE,
trim(translate(replace(INPAT_INFECTIVITY_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_INFECTIVITY_MARK,
trim(translate(replace(INPAT_ILL_STATE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_ILL_STATE_CODE,
trim(translate(replace(OTHER_MEDICAL_TREATMENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OTHER_MEDICAL_TREATMENT,
trim(translate(replace(REFERRAL_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERRAL_MARK,
trim(translate(replace(DISCHARGE_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISCHARGE_DATE,
trim(translate(replace(DEATH_REASON_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEATH_REASON_CODE,
trim(translate(replace(DEATH_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEATH_DTIME,
trim(translate(replace(SEC_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEC_TYPE_CODE,
trim(translate(replace(SEC_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEC_NO,
trim(translate(replace(IS_LOCAL_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IS_LOCAL_MARK,
trim(translate(replace(IN_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DEPT_CODE,
trim(translate(replace(IN_BED,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_BED,
trim(translate(replace(OUT_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DEPT_NAME,
trim(translate(replace(OUT_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DEPT_CODE,
trim(translate(replace(OUT_BED,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_BED,
trim(translate(replace(DEATH_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEATH_MARK,
trim(translate(replace(STD_OUT_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))STD_OUT_DEPT_CODE,
trim(translate(replace(STD_IN_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))STD_IN_DEPT_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME  from  inpatient   where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_consult) 
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(CONSULT_RECORD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_RECORD_NO,
trim(translate(replace(CONSULT_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_ORG_NAME,
trim(translate(replace(CONSULT_ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_ORG_CODE,
trim(translate(replace(CONSULT_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_DATE,
trim(translate(replace(CONSULT_REASON,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_REASON,
trim(translate(replace(CONSULT_ADVICE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_ADVICE,
trim(translate(replace(CONSULT_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_DOCTOR_NAME,
trim(translate(replace(RESP_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESP_DOCTOR_NAME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_CODE,
trim(translate(replace(DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_NAME,
trim(translate(replace(WARD_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))WARD_NAME,
trim(translate(replace(DEPT_ROOM,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_ROOM,
trim(translate(replace(BED_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BED_NO,
trim(translate(replace(MEDICAL_RECORD_DIGEST,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDICAL_RECORD_DIGEST,
trim(translate(replace(ASSIST_EXAM_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSIST_EXAM_RESULT,
trim(translate(replace(TCM_OBSERVE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TCM_OBSERVE,
trim(translate(replace(THERAPEUTIC_PRINCIPLES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))THERAPEUTIC_PRINCIPLES,
trim(translate(replace(TREAT_DIAG_PROCESS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREAT_DIAG_PROCESS_NAME,
trim(translate(replace(TREAT_RESCUE_COURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREAT_RESCUE_COURSE,
trim(translate(replace(CONSULTATION_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULTATION_TYPE,
trim(translate(replace(CONSULTATION_PURPOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULTATION_PURPOSE,
trim(translate(replace(APPLY_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT,
trim(translate(replace(CONSULTATION_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULTATION_DEPT    from  inpatient_consult
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_consult   where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_consult
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_drug)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(CN_MEDICINE_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CN_MEDICINE_TYPE_CODE,
trim(translate(replace(DRUG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_NAME,
trim(translate(replace(DRUG_FORM_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_FORM_CODE,
trim(translate(replace(DRUG_USING_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_USING_DAYS,
trim(translate(replace(DRUG_USING_FREQ,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_USING_FREQ,
trim(translate(replace(DRUG_DOSE_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_DOSE_UNIT,
trim(translate(replace(DRUG_PER_DOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_PER_DOSE,
trim(translate(replace(DRUG_TOTAL_DOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_TOTAL_DOSE,
trim(translate(replace(DRUG_ROUTE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_ROUTE_CODE,
trim(translate(replace(DRUG_STOP_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_STOP_DTIME,
trim(translate(replace(DRUG_LOCAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_LOCAL_CODE,
trim(translate(replace(DRUG_STD_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_STD_NAME,
trim(translate(replace(DRUG_STD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_STD_CODE,
trim(translate(replace(DRUG_TOTAL_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_TOTAL_UNIT,
trim(translate(replace(SPEC,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPEC,
trim(translate(replace(GROUP_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))GROUP_NO,
trim(translate(replace(DRUG_START_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_START_DTIME,
trim(translate(replace(DISPENSING_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISPENSING_DTIME,
trim(translate(replace(NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NOTES,
trim(translate(replace(DRUG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_TYPE_CODE,
trim(translate(replace(DDD_VALUE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DDD_VALUE,
trim(translate(replace(ANTIBACTERIAL_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANTIBACTERIAL_FLAG,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(CRUCIAL_DRUG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CRUCIAL_DRUG_NAME,
trim(translate(replace(CRUCIAL_DRUG_USAGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CRUCIAL_DRUG_USAGE,
trim(translate(replace(DRUG_ADVERSE_REACTION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_ADVERSE_REACTION  from inpatient_drug   where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_drug  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_drug
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_fee)
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(INPAT_FEE_TYPE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FEE_TYPE_NAME,
trim(translate(replace(INPAT_FEE_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FEE_TYPE_CODE,
trim(translate(replace(INPAT_FEE_AMOUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FEE_AMOUNT,
trim(translate(replace(PAY_WAY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAY_WAY_CODE,
trim(translate(replace(INPAT_SETTLE_WAY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_SETTLE_WAY_CODE,
trim(translate(replace(PRICE_ITEM_LOCAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE_ITEM_LOCAL_CODE,
trim(translate(replace(PRICE_ITEM_STD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE_ITEM_STD_CODE,
trim(translate(replace(DEDUCT_FEES_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEDUCT_FEES_DTIME,
trim(translate(replace(SPEC,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPEC,
trim(translate(replace(UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))UNIT,
trim(translate(replace(PRICE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE,
trim(translate(replace(QUANTITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))QUANTITY,
trim(translate(replace(NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NOTES,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(PRICE_ITEM_LOCAL_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE_ITEM_LOCAL_NAME,
trim(translate(replace(SELF_PAYMENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SELF_PAYMENT,
trim(translate(replace(BABY_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BABY_FLAG,
trim(translate(replace(APPLY_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT_CODE,
trim(translate(replace(APPLY_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT_NAME,
trim(translate(replace(APPLY_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DOCTOR,
trim(translate(replace(EXEC_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXEC_DEPT_CODE,
trim(translate(replace(EXEC_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXEC_DEPT_NAME,
trim(translate(replace(EXEC_MAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXEC_MAN,
trim(translate(replace(CHARGES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHARGES,
trim(translate(replace(INSURANCE_CHARGES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INSURANCE_CHARGES,
trim(translate(replace(DERATE_CHARGES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DERATE_CHARGES,
trim(translate(replace(OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATOR,
trim(translate(replace(CINSUR_PERCENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CINSUR_PERCENT    from inpatient_fee   where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_fee  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_fee
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_firstoper)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(REPORT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_FORM_NO,
trim(translate(replace(OPER_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPER_FORM_NO,
trim(translate(replace(OPERATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_CODE,
trim(translate(replace(OPERATION_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_DTIME,
trim(translate(replace(OPERATION_LEVEL_CD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_LEVEL_CD,
trim(translate(replace(OPERATION_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_NAME,
trim(translate(replace(SURGEON_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SURGEON_NAME,
trim(translate(replace(ASSISTANT1_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSISTANT1_NAME,
trim(translate(replace(ASSISTANT2_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSISTANT2_NAME,
trim(translate(replace(INCISION_HEALING_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INCISION_HEALING_CODE,
trim(translate(replace(ANESTHESIA_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANESTHESIA_CODE,
trim(translate(replace(ANESTHESIOLOGIST_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANESTHESIOLOGIST_NAME,
trim(translate(replace(BODY_PART,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BODY_PART,
trim(translate(replace(BODY_PART_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BODY_PART_NAME,
trim(translate(replace(OPER_DURATION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPER_DURATION,
trim(translate(replace(ANESTHESIA_LEVEL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANESTHESIA_LEVEL_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(CASE_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CASE_TYPE,
trim(translate(replace(INCISION_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INCISION_TYPE_CODE   from  inpatient_firstoper  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_firstoper  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_firstoper
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_firstoutdiag)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(REPORT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_FORM_NO,
trim(translate(replace(DIAGNOSIS_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_ID,
trim(translate(replace(ORG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_TYPE_CODE,
trim(translate(replace(DIAGNOSIS_CD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_CD,
trim(translate(replace(IN_CONDITION_CD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CONDITION_CD,
trim(translate(replace(LAST_DIAGNOSIS_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_DIAGNOSIS_DATE,
trim(translate(replace(DIAG_RESULT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_RESULT_CODE,
trim(translate(replace(PATHOLOGICAL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATHOLOGICAL_NO,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(CASE_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CASE_TYPE,
trim(translate(replace(DIAGNOSIS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_NAME,
trim(translate(replace(DIAG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_TYPE_CODE,
trim(translate(replace(DIAG_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_TYPE    from  inpatient_firstoutdiag
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_firstoutdiag  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_firstoutdiag
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_firstpage)  
sql_str="
select
 last_update_dtime           ,
 org_code                    ,
 patient_id                  ,
 inpat_form_no               ,
 report_form_no              ,
 card_no                     ,
 in_hospital_times           ,
 case_no                     ,
 pay_way_code                ,
 name                        ,
 sex_code                    ,
 birth_date                  ,
 age                         ,
 country_code                ,
 birth_weight                ,
 in_weight                   ,
 birth_addr_province         ,
 birth_addr_city             ,
 birth_addr_county           ,
 birth_addr_town             ,
 birth_addr_village          ,
 birth_addr_house_no         ,
 native_province             ,
 native_city                 ,
 nationality_code            ,
 id_type_code                ,
 id_no                       ,
 occupation_code             ,
 marriage_code               ,
 present_addr_province       ,
 present_addr_city           ,
 present_addr_county         ,
 present_addr_town           ,
 present_addr_village        ,
 present_addr_house_no       ,
 present_addr_tel_no         ,
 present_addr_postal_code    ,
 register_addr_province      ,
 register_addr_city          ,
 register_addr_county        ,
 register_addr_town          ,
 register_addr_village       ,
 register_addr_house_no      ,
 employer_name               ,
 employer_addr_province      ,
 employer_addr_city          ,
 employer_addr_county        ,
 employer_addr_town          ,
 employer_addr_village       ,
 employer_addr_house_no      ,
 employer_tel_no             ,
 employer_postal_code        ,
 contact_name                ,
 contact_relationship_cd     ,
 contact_address             ,
 contact_tel_no              ,
 in_path_code                ,
 admission_dtime             ,
 in_dept_code                ,
 in_dept_name                ,
 in_dept_room                ,
 move_dept_code              ,
 move_dept_name              ,
 discharge_dtime             ,
 out_dept_code               ,
 out_dept_name               ,
 out_dept_room               ,
 actual_in_days              ,
 outpat_diag_code            ,
 outpat_diag_name            ,
 damage_poison_reason        ,
 damage_poison_icd_cd        ,
 drug_allergy_mark           ,
 drug_allergens_name         ,
 autopsy_mark                ,
 abo_code                    ,
 rh_code                     ,
 rh_name                     ,
 dept_director_id            ,
 dept_director_name          ,
 chief_doctor_id             ,
 chief_doctor_name           ,
 in_charge_doctor_id         ,
 in_charge_doctor_name       ,
 resident_doctor_id          ,
 resident_doctor_name        ,
 resp_nurse_id               ,
 resp_nurse_name             ,
 learning_doctor_id          ,
 learning_doctor_name        ,
 intern_doctor_id            ,
 intern_doctor_name          ,
 cataloger_id                ,
 cataloger_name              ,
 case_quality_cd             ,
 qc_doctor_id                ,
 qc_doctor_name              ,
 qc_nurse_id                 ,
 qc_nurse_name               ,
 qc_dtime                    ,
 discharge_class_cd          ,
 order_referral_org          ,
 rehosp_after31_mark         ,
 rehosp_after31_purpose      ,
 coma_duration_before        ,
 coma_duration_after         ,
 fee_total                   ,
 fee_self_pay                ,
 fee_general_medical         ,
 fee_general_treat           ,
 fee_tend                    ,
 fee_medical_other           ,
 fee_pathology               ,
 fee_laboratory              ,
 fee_imaging                 ,
 fee_clinc                   ,
 fee_nonsurgical_treat       ,
 fee_clin_physical           ,
 fee_surgical_treat          ,
 fee_anaes                   ,
 fee_operation               ,
 fee_recovery                ,
 fee_cn_treatment            ,
 fee_western_medicine        ,
 fee_antimicrobial           ,
 fee_cn_medicine             ,
 fee_cn_herbal_medicine      ,
 fee_blood                   ,
 fee_albumin                 ,
 fee_globulin                ,
 fee_bcf                     ,
 fee_cytokine                ,
 fee_check_material          ,
 fee_treat_material          ,
 fee_oper_material           ,
 fee_other                   ,
 fee_baby                    ,
 fee_extra_bed               ,
 fee_bed                     ,
 fee_radiation               ,
 fee_assay                   ,
 fee_oxygen                  ,
 fee_deliver                 ,
 fee_check                   ,
 effective_time              ,
 death_cause                 ,
 root_death_code             ,
 infusion_reaction_mark      ,
 follow_interval             ,
 research_example_mark       ,
 first_operation_mark        ,
 first_treatment_mark        ,
 first_exam_mark             ,
 first_diagnosis_mark        ,
 infectious_mark             ,
 infectious_type_code        ,
 infectious_reported_mark    ,
 register_addr_postal_code   ,
 infectiousness_times        ,
 insurance_no                ,
 in_condition_code           ,
 allergens_code              ,
 hbsag_code                  ,
 hcv_ab_code                 ,
 hiv_ab_code                 ,
 clinic2out_code             ,
 in2out_code                 ,
 pre_oper2oper_code          ,
 radiation2oper_code         ,
 clinic2pathology_code       ,
 radiation2pathology_code    ,
 clinic2autopsy_code         ,
 save_times                  ,
 save_success_times          ,
 diag_basis_code             ,
 differ_level_code           ,
 graduate_intern_doctor_name ,
 protect_special             ,
 protect_i                   ,
 protect_ii                  ,
 protect_iii                 ,
 intensive_care_therapy      ,
 oper_patient_type_code      ,
 follow_up_weeks             ,
 follow_up_months            ,
 follow_up_years             ,
 teaching_example_mark       ,
 transfusion_reaction_mark   ,
 red_blood_cell              ,
 platelet                    ,
 plasma                      ,
 whole_blood                 ,
 self_blood                  ,
 other_blood                 ,
 follow_mark                 ,
 age_baby                    ,
 life_support_machine_time   ,
 ref_in_org_name             ,
 in_dept_type_code           ,
 in_dept_type_name           ,
 move_dept_type_code         ,
 move_dept_type_name         ,
 out_dept_type_code          ,
 out_dept_type_name          ,
 death_dtime                 ,
 zoe_sys_client_code         ,
 zoe_sys_collect_time        ,
 contact_province            ,
 contact_city                ,
 contact_county              ,
 contact_village             ,
 contact_countryside         ,
 contact_door                ,
 clinical_pathway_code       
from inpatient_firstpage 
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_firstpage  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_firstpage
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_indiag)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(DIAGNOSIS_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_ID,
trim(translate(replace(IN_DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DIAG_NAME,
trim(translate(replace(IN_DIAG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DIAG_CODE,
trim(translate(replace(CONFIRMED_DIAG_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONFIRMED_DIAG_DATE,
trim(translate(replace(PROPERTY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PROPERTY_CODE,
trim(translate(replace(DIAG_RESULT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_RESULT_CODE,
trim(translate(replace(DIAG_EXPLAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_EXPLAN,
trim(translate(replace(DIAG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_TYPE_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME  from inpatient_indiag
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_indiag  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_indiag
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_inrecord)
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_DATE,
trim(translate(replace(AGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AGE,
trim(translate(replace(ADDRESS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDRESS,
trim(translate(replace(EMPLOYER_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EMPLOYER_NAME,
trim(translate(replace(BIRTH_ADDRESS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_ADDRESS,
trim(translate(replace(NATIONALITY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NATIONALITY_CODE,
trim(translate(replace(OCCUPATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OCCUPATION_CODE,
trim(translate(replace(MARRIAGE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MARRIAGE_CODE,
trim(translate(replace(REPRESENTOR_RELATIONSHIP,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPRESENTOR_RELATIONSHIP,
trim(translate(replace(REPRESENTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPRESENTOR_NAME,
trim(translate(replace(REPRESENT_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPRESENT_DTIME,
trim(translate(replace(AUTHOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_ID,
trim(translate(replace(AUTHOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_NAME,
trim(translate(replace(AUTHOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_DTIME,
trim(translate(replace(AUTHENTICATOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHENTICATOR_ID,
trim(translate(replace(AUTHENTICATOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHENTICATOR_NAME,
trim(translate(replace(AUTHENTICATOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHENTICATOR_DTIME,
trim(translate(replace(IN_CHARGE_DOCTOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHARGE_DOCTOR_ID,
trim(translate(replace(IN_CHARGE_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHARGE_DOCTOR_NAME,
trim(translate(replace(IN_CHARGE_DOCTOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHARGE_DOCTOR_DTIME,
trim(translate(replace(INRECORD_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INRECORD_TYPE_CODE,
trim(translate(replace(ADMISSION_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADMISSION_DTIME,
trim(translate(replace(DEATH_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEATH_DTIME,
trim(translate(replace(IN_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DEPT_CODE,
trim(translate(replace(IN_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DEPT_NAME,
trim(translate(replace(BED_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BED_NO,
trim(translate(replace(CHIEF_COMPLAINTS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHIEF_COMPLAINTS,
trim(translate(replace(CURRENT_DISEASE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CURRENT_DISEASE,
trim(translate(replace(DISEASE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISEASE_HISTORY,
trim(translate(replace(PERSONAL_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERSONAL_HISTORY,
trim(translate(replace(MARRIAGE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MARRIAGE_HISTORY,
trim(translate(replace(MENSES_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MENSES_HISTORY,
trim(translate(replace(FAMILY_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FAMILY_HISTORY,
trim(translate(replace(SPEC_SITUATION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPEC_SITUATION,
trim(translate(replace(ASSIST_EXAM_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSIST_EXAM_RESULT,
trim(translate(replace(FIRST_DIAGNOSIS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FIRST_DIAGNOSIS,
trim(translate(replace(FIRST_DIAGNOSIS_ICD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FIRST_DIAGNOSIS_ICD,
trim(translate(replace(INPAT_DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_DIAG_NAME,
trim(translate(replace(IN_DIAGNOSIS_ICD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DIAGNOSIS_ICD,
trim(translate(replace(IN_CONDITION_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CONDITION_DESCR,
trim(translate(replace(TREAT_RESCUE_COURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREAT_RESCUE_COURSE,
trim(translate(replace(OUT_CONDITION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_CONDITION,
trim(translate(replace(OUT_DIAGNOSIS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DIAGNOSIS_NAME,
trim(translate(replace(OUT_DIAGNOSIS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DIAGNOSIS_CODE,
trim(translate(replace(OUT_ORDER,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_ORDER,
trim(translate(replace(TREATMENT_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREATMENT_RESULT,
trim(translate(replace(DEATH_CAUSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEATH_CAUSE,
trim(translate(replace(DEATH_DIAGNOSIS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEATH_DIAGNOSIS,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(RELIABLE_STATEMENT_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RELIABLE_STATEMENT_FLAG,
trim(translate(replace(GENERAL_HEALTH_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))GENERAL_HEALTH_FLAG,
trim(translate(replace(INFECTIOUS_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INFECTIOUS_FLAG,
trim(translate(replace(INFECTION_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INFECTION_HISTORY,
trim(translate(replace(VACCINATE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VACCINATE_HISTORY,
trim(translate(replace(OPERATION_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_HISTORY,
trim(translate(replace(BLOOD_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BLOOD_HISTORY,
trim(translate(replace(ALLERGY_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ALLERGY_HISTORY,
trim(translate(replace(TCM_OBSERVE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TCM_OBSERVE,
trim(translate(replace(THERAPEUTIC_PRINCIPLES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))THERAPEUTIC_PRINCIPLES,
trim(translate(replace(ACCEPT_PHYSICIAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ACCEPT_PHYSICIAN,
trim(translate(replace(RESIDENT_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESIDENT_DOCTOR_NAME,
trim(translate(replace(TEND_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TEND_DEPT_CODE,
trim(translate(replace(VISIT_TEND_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_TEND_DEPT_NAME,
trim(translate(replace(NURSE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NURSE_NAME,
trim(translate(replace(NURSE_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NURSE_ID    from inpatient_inrecord
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_inrecord  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_inrecord
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_longorder)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(ORDER_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_ID,
trim(translate(replace(ORDER_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_DTIME,
trim(translate(replace(ORDER_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_DOCTOR,
trim(translate(replace(CHECK_NURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHECK_NURSE,
trim(translate(replace(ORDER_STOP_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_STOP_DTIME,
trim(translate(replace(ORDER_STOP_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_STOP_DOCTOR,
trim(translate(replace(ORDER_STOP_NURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_STOP_NURSE,
trim(translate(replace(ORDER_LOCAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_LOCAL_CODE,
trim(translate(replace(ORDER_STD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_STD_CODE,
trim(translate(replace(ORDER_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_NAME,
trim(translate(replace(ORDER_FREQ,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_FREQ,
trim(translate(replace(ORDER_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_FORM_NO,
trim(translate(replace(ORDER_ITEM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_ITEM_NO,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(SUBJECT_CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SUBJECT_CLASS_CODE,
trim(translate(replace(PLAN_START_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PLAN_START_TIME,
trim(translate(replace(PLAN_END_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PLAN_END_TIME,
trim(translate(replace(REAMRK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REAMRK,
trim(translate(replace(APPLY_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT,
trim(translate(replace(AUDITOR_SIGNATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUDITOR_SIGNATURE,
trim(translate(replace(AUDIT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUDIT_TIME,
trim(translate(replace(CHECK_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHECK_TIME,
trim(translate(replace(PERFORMER_SIGNATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORMER_SIGNATURE,
trim(translate(replace(PERFORM_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_TIME,
trim(translate(replace(PERFORM_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_DEPT,
trim(translate(replace(PERFORM_STATUS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_STATUS    from inpatient_longorder
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_longorder  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_longorder
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_outdiag) 
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(DIAGNOSIS_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_ID,
trim(translate(replace(OUT_DIAG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DIAG_CODE,
trim(translate(replace(TREAT_RESULT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREAT_RESULT_CODE,
trim(translate(replace(PROPERTY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PROPERTY_CODE,
trim(translate(replace(DIAG_EXPLAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_EXPLAN,
trim(translate(replace(DIAG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_TYPE_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(OUT_DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DIAG_NAME   from  inpatient_outdiag
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_outdiag  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_outdiag
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_outsummary) 
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_DATE,
trim(translate(replace(AGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AGE,
trim(translate(replace(ADDRESS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDRESS,
trim(translate(replace(EMPLOYER_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EMPLOYER_NAME,
trim(translate(replace(BIRTH_ADDRESS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_ADDRESS,
trim(translate(replace(NATIONALITY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NATIONALITY_CODE,
trim(translate(replace(OCCUPATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OCCUPATION_CODE,
trim(translate(replace(MARRIAGE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MARRIAGE_CODE,
trim(translate(replace(RESIDENT_DOCTOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESIDENT_DOCTOR_ID,
trim(translate(replace(RESIDENT_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESIDENT_DOCTOR_NAME,
trim(translate(replace(RESIDENT_DOCTOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESIDENT_DOCTOR_DTIME,
trim(translate(replace(IN_CHARGE_DOCTOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHARGE_DOCTOR_ID,
trim(translate(replace(IN_CHARGE_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHARGE_DOCTOR_NAME,
trim(translate(replace(IN_CHARGE_DOCTOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHARGE_DOCTOR_DTIME,
trim(translate(replace(OUTSUMMARY_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTSUMMARY_TYPE_CODE,
trim(translate(replace(ADMISSION_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADMISSION_DTIME,
trim(translate(replace(DISCHARGE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISCHARGE_DTIME,
trim(translate(replace(IN_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DEPT_CODE,
trim(translate(replace(IN_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DEPT_NAME,
trim(translate(replace(BED_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BED_NO,
trim(translate(replace(IN_HOSPITAL_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_HOSPITAL_DAYS,
trim(translate(replace(IN_DIAGNOSIS_ICD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_DIAGNOSIS_ICD,
trim(translate(replace(INPAT_DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_DIAG_NAME,
trim(translate(replace(IN_CONDITION_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CONDITION_DESCR,
trim(translate(replace(TREAT_RESCUE_COURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREAT_RESCUE_COURSE,
trim(translate(replace(OUT_CONDITION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_CONDITION,
trim(translate(replace(OUT_DIAGNOSIS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DIAGNOSIS_CODE,
trim(translate(replace(OUT_DIAGNOSIS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_DIAGNOSIS_NAME,
trim(translate(replace(OUT_ORDER,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_ORDER,
trim(translate(replace(TREATMENT_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREATMENT_RESULT,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(AUXILIARY_POSITIVE_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUXILIARY_POSITIVE_RESULT,
trim(translate(replace(TCM_OBSERVE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TCM_OBSERVE,
trim(translate(replace(OPERATION_DESCRIBE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_DESCRIBE,
trim(translate(replace(THERAPEUTIC_PRINCIPLES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))THERAPEUTIC_PRINCIPLES,
trim(translate(replace(TCM_DECOCTION_METHOD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TCM_DECOCTION_METHOD,
trim(translate(replace(TCM_USE_METHOD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TCM_USE_METHOD,
trim(translate(replace(DISCHARGE_SYMPTOM_SIGN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISCHARGE_SYMPTOM_SIGN  from inpatient_outsummary
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_outsummary  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_outsummary
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_proorder)
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(ORDER_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_ID,
trim(translate(replace(ORDER_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_DTIME,
trim(translate(replace(ORDER_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_DOCTOR,
trim(translate(replace(CHECK_NURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHECK_NURSE,
trim(translate(replace(PERFORM_NURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_NURSE,
trim(translate(replace(PERFORM_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_DTIME,
trim(translate(replace(ORDER_LOCAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_LOCAL_CODE,
trim(translate(replace(ORDER_STD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_STD_CODE,
trim(translate(replace(ORDER_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_NAME,
trim(translate(replace(ORDER_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_FORM_NO,
trim(translate(replace(ORDER_ITEM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_ITEM_NO,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(SUBJECT_CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SUBJECT_CLASS_CODE,
trim(translate(replace(PLAN_START_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PLAN_START_TIME,
trim(translate(replace(PLAN_END_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PLAN_END_TIME,
trim(translate(replace(REAMRK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REAMRK,
trim(translate(replace(APPLY_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT,
trim(translate(replace(AUDITOR_SIGNATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUDITOR_SIGNATURE,
trim(translate(replace(AUDIT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUDIT_TIME,
trim(translate(replace(CHECK_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHECK_TIME,
trim(translate(replace(PERFORM_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_DEPT,
trim(translate(replace(PERFORM_STATUS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORM_STATUS,
trim(translate(replace(CANCEL_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CANCEL_TIME,
trim(translate(replace(CANCEL_OPERATOR_SIGNATURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CANCEL_OPERATOR_SIGNATURE from inpatient_proorder
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_proorder  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_proorder
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

inpatient_symp)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(SYMPTOM_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMPTOM_ID,
trim(translate(replace(SYMPTOM_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMPTOM_NAME,
trim(translate(replace(SYMPTOM_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMPTOM_CODE,
trim(translate(replace(ONSET_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ONSET_DTIME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from inpatient_symp
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.inpatient_symp  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.inpatient_symp
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

lab_drug_sen) 
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_NO,
trim(translate(replace(REPORT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_FORM_NO,
trim(translate(replace(SERIAL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SERIAL_NO,
trim(translate(replace(DRUG_RESULT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_RESULT_ID,
trim(translate(replace(DRUG_SENSITIVITY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_SENSITIVITY_CODE,
trim(translate(replace(DRUG_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_RESULT,
trim(translate(replace(PIECE_DRUG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PIECE_DRUG,
trim(translate(replace(BACSTA_CONCEN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BACSTA_CONCEN,
trim(translate(replace(BACSTA_DIAMETER,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BACSTA_DIAMETER,
trim(translate(replace(ANTIBIOTICS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANTIBIOTICS_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(ANTIBIOTICS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANTIBIOTICS_NAME    from lab_drug_sen
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.lab_drug_sen  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.lab_drug_sen
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

lab_subitem)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_NO,
trim(translate(replace(REPORT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_FORM_NO,
trim(translate(replace(SERIAL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SERIAL_NO,
trim(translate(replace(CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CLASS_CODE,
trim(translate(replace(RESULT_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_TYPE,
trim(translate(replace(RESULT_VALUE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_VALUE,
trim(translate(replace(RESULT_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_UNIT,
trim(translate(replace(NORM_LOWER_LIMIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NORM_LOWER_LIMIT,
trim(translate(replace(NORM_UPPER_LIMIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NORM_UPPER_LIMIT,
trim(translate(replace(NORM_VALUE_NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NORM_VALUE_NOTES,
trim(translate(replace(RESULT_INTERPRE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESULT_INTERPRE,
trim(translate(replace(EFFECTIVE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EFFECTIVE_DTIME,
trim(translate(replace(EXAMINE_WAY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXAMINE_WAY,
trim(translate(replace(RECOGNITION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RECOGNITION,
trim(translate(replace(CLASS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CLASS_NAME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from lab_subitem
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.lab_subitem  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.lab_subitem
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

labmaster)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(EVENT_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_TYPE,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_NO,
trim(translate(replace(REPORT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_FORM_NO,
trim(translate(replace(RETRIEVE_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RETRIEVE_DATE,
trim(translate(replace(REPORT_TITLE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_TITLE,
trim(translate(replace(EFFECTIVE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EFFECTIVE_DTIME,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(AUTHOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_ID,
trim(translate(replace(REPORT_CREATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REPORT_CREATE_DTIME,
trim(translate(replace(AUTHOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_NAME,
trim(translate(replace(AUTHENTICATOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHENTICATOR_ID,
trim(translate(replace(AUTHENTICATOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHENTICATOR_DTIME,
trim(translate(replace(AUTHENTICATOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHENTICATOR_NAME,
trim(translate(replace(PARTICIPANT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PARTICIPANT_ID,
trim(translate(replace(PARTICIPANT_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PARTICIPANT_DTIME,
trim(translate(replace(PARTICIPANT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PARTICIPANT_NAME,
trim(translate(replace(PARTICIPANT_DEPT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PARTICIPANT_DEPT,
trim(translate(replace(ORDER_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_ID,
trim(translate(replace(ORDER_PRIORITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORDER_PRIORITY,
trim(translate(replace(SPECIMEN_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_ID,
trim(translate(replace(SPECIMEN_DETERMINER_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_DETERMINER_CODE,
trim(translate(replace(SPECIMEN_RISK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_RISK,
trim(translate(replace(SPECIMEN_QUANTITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_QUANTITY,
trim(translate(replace(SPECIMEN_REJECTREASON,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_REJECTREASON,
trim(translate(replace(PERFORMER_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORMER_DEPT_NAME,
trim(translate(replace(PERFORMER_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PERFORMER_DOCTOR,
trim(translate(replace(LAB_PERFORMER_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAB_PERFORMER_DTIME,
trim(translate(replace(RECOGNITION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RECOGNITION,
trim(translate(replace(SPECIMEN_CLASS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_CLASS,
trim(translate(replace(CATALOG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CATALOG_NAME,
trim(translate(replace(CATALOG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CATALOG_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(SPECIMEN_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_NAME,
trim(translate(replace(SPECIMEN_STATUS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_STATUS,
trim(translate(replace(DIAGNOSIS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_CODE,
trim(translate(replace(DIAGNOSIS_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_NAME,
trim(translate(replace(DIAG_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_ORG_NAME,
trim(translate(replace(DIAG_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_DATE,
trim(translate(replace(BLOOD_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BLOOD_DATE,
trim(translate(replace(SPECIMEN_RECEIVE_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_RECEIVE_TIME,
trim(translate(replace(LAB_METHOD_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAB_METHOD_NAME,
trim(translate(replace(LAB_INSTRUMENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAB_INSTRUMENT,
trim(translate(replace(LAB_PURPOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAB_PURPOSE,
trim(translate(replace(SPECIMEN_COLLECT_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_COLLECT_OPERATOR,
trim(translate(replace(SPECIMEN_ACCEPT_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPECIMEN_ACCEPT_OPERATOR,
trim(translate(replace(BARCODE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BARCODE_NO,
trim(translate(replace(PRINT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRINT_TIME,
trim(translate(replace(PRINT_OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRINT_OPERATOR  from labmaster
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.labmaster  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.labmaster
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

mid_base_resour_income_mon)       
sql_str="
select
trim(translate(replace(DIM_MONTH,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIM_MONTH,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_NAME,
trim(translate(replace(OP_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_FEE,
trim(translate(replace(OP_REG_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_REG_FEE,
trim(translate(replace(OP_INSPECT_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_INSPECT_FEE,
trim(translate(replace(OP_CHECK_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_CHECK_FEE,
trim(translate(replace(OP_TEST_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_TEST_FEE,
trim(translate(replace(OP_TREATMENT_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_TREATMENT_FEE,
trim(translate(replace(OP_OPERATE_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_OPERATE_FEE,
trim(translate(replace(OP_MATERIAL_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_MATERIAL_FEE,
trim(translate(replace(OP_MED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_MED_FEE,
trim(translate(replace(OP_ESS_NATN_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_ESS_NATN_FEE,
trim(translate(replace(OP_ESS_PROV_SUP_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_ESS_PROV_SUP_FEE,
trim(translate(replace(OP_WESTERN_MED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_WESTERN_MED_FEE,
trim(translate(replace(OP_CN_HERBAL_MED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_CN_HERBAL_MED_FEE,
trim(translate(replace(OP_CN_PATENT_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_CN_PATENT_FEE,
trim(translate(replace(OP_OTH_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_OTH_FEE,
trim(translate(replace(IN_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_FEE,
trim(translate(replace(IN_BED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_BED_FEE,
trim(translate(replace(IN_INSPECT_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_INSPECT_FEE,
trim(translate(replace(IN_CHECK_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CHECK_FEE,
trim(translate(replace(IN_TEST_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_TEST_FEE,
trim(translate(replace(IN_TREATMENT_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_TREATMENT_FEE,
trim(translate(replace(IN_OPERATE_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_OPERATE_FEE,
trim(translate(replace(IN_NURSING_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_NURSING_FEE,
trim(translate(replace(IN_MATERIAL_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_MATERIAL_FEE,
trim(translate(replace(IN_MED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_MED_FEE,
trim(translate(replace(IN_ESS_NATN_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_ESS_NATN_FEE,
trim(translate(replace(IN_ESS_PROV_SUP_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_ESS_PROV_SUP_FEE,
trim(translate(replace(IN_WESTERN_MED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_WESTERN_MED_FEE,
trim(translate(replace(IN_CN_HERBAL_MED_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CN_HERBAL_MED_FEE,
trim(translate(replace(IN_CN_PATENT_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_CN_PATENT_FEE,
trim(translate(replace(IN_OTH_FEE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IN_OTH_FEE,
trim(translate(replace(TOTAL_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TOTAL_EXPD,
trim(translate(replace(MEDICAL_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDICAL_EXPD,
trim(translate(replace(CLIN_SVR_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CLIN_SVR_EXPD,
trim(translate(replace(MEDICAL_TECH_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDICAL_TECH_EXPD,
trim(translate(replace(MEDICAL_ASS_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDICAL_ASS_EXPD,
trim(translate(replace(FINAC_ALC_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FINAC_ALC_EXPD,
trim(translate(replace(EDU_ITEM_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EDU_ITEM_EXPD,
trim(translate(replace(MNG_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MNG_EXPD,
trim(translate(replace(RETIRED_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RETIRED_EXPD,
trim(translate(replace(STAFF_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))STAFF_EXPD,
trim(translate(replace(BASE_WAGE_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BASE_WAGE_EXPD,
trim(translate(replace(ALLOWANCE_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ALLOWANCE_EXPD,
trim(translate(replace(BONUS_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BONUS_EXPD,
trim(translate(replace(MERIT_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MERIT_EXPD,
trim(translate(replace(MATERIAL_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MATERIAL_EXPD,
trim(translate(replace(MED_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MED_EXPD,
trim(translate(replace(ESS_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ESS_EXPD,
trim(translate(replace(FINANCE_SUB_INCOME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FINANCE_SUB_INCOME,
trim(translate(replace(INTRO_TALENTS_EXPD,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INTRO_TALENTS_EXPD,
trim(translate(replace(MEDC_ACCI_COPST_FUNDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDC_ACCI_COPST_FUNDS,
trim(translate(replace(TOTAL_ASSET_FUNDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TOTAL_ASSET_FUNDS,
trim(translate(replace(FLOW_ASSET_FUNDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FLOW_ASSET_FUNDS,
trim(translate(replace(NET_ASSET_FUNDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NET_ASSET_FUNDS,
trim(translate(replace(DEBT_FUNDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEBT_FUNDS,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME  from mid_base_resour_income_mon"
delete_sql="delete from  wj_data.mid_base_resour_income_mon"
select_sql="
select count(1)
  from wj_data.mid_base_resour_income_mon";;

mid_base_resour_org_year)
sql_str="
select
trim(translate(replace(DIM_YEAR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIM_YEAR,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_NAME,
trim(translate(replace(DEPT_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_CN,
trim(translate(replace(ACT_BED_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ACT_BED_CN,
trim(translate(replace(DOCTOR_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DOCTOR_CN,
trim(translate(replace(CERTIFIED_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTIFIED_DOC_CN,
trim(translate(replace(REG_NURSE_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REG_NURSE_CN,
trim(translate(replace(PHARMACIST_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PHARMACIST_CN,
trim(translate(replace(HEATH_TECHCS_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEATH_TECHCS_CN,
trim(translate(replace(OTH_TECHCS_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OTH_TECHCS_CN,
trim(translate(replace(OTH_TECHCS_INT_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OTH_TECHCS_INT_DOC_CN,
trim(translate(replace(MANAGER_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MANAGER_CN,
trim(translate(replace(GRND_SKILL_STAFF_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))GRND_SKILL_STAFF_CN,
trim(translate(replace(TEST_TECHCS_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TEST_TECHCS_CN,
trim(translate(replace(IMG_TECHCS_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IMG_TECHCS_CN,
trim(translate(replace(ESP_SVR_BED_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ESP_SVR_BED_CN,
trim(translate(replace(ACT_OPEN_BED_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ACT_OPEN_BED_DAYS,
trim(translate(replace(ACT_OCCU_BED_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ACT_OCCU_BED_DAYS,
trim(translate(replace(OUT_OCCU_BED_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_OCCU_BED_DAYS,
trim(translate(replace(OBS_BED_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OBS_BED_DAYS,
trim(translate(replace(OUT_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUT_CN,
trim(translate(replace(BUILD_AREA,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BUILD_AREA,
trim(translate(replace(MEDICAL_USE_AREA,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDICAL_USE_AREA,
trim(translate(replace(MEDICAL_DILPT_AREA,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MEDICAL_DILPT_AREA,
trim(translate(replace(BUILD_RENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BUILD_RENT,
trim(translate(replace(UP_TEN_THOUS_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))UP_TEN_THOUS_CN,
trim(translate(replace(BET_10_49_W_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BET_10_49_W_CN,
trim(translate(replace(BET_50_99_W_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BET_50_99_W_CN,
trim(translate(replace(UP_100_W_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))UP_100_W_CN,
trim(translate(replace(UP_TEN_THS_WORTH,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))UP_TEN_THS_WORTH,
trim(translate(replace(BUILD_RENT_AREA,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BUILD_RENT_AREA,
trim(translate(replace(BUILD_RENT_USE_AREA,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BUILD_RENT_USE_AREA,
trim(translate(replace(FORMATION_BEDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))FORMATION_BEDS,
trim(translate(replace(NEG_PRESS_BEDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NEG_PRESS_BEDS,
trim(translate(replace(PICU_BEDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PICU_BEDS,
trim(translate(replace(RICUBEDS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RICUBEDS,
trim(translate(replace(CERTFD_ASS_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_ASS_DOC_CN,
trim(translate(replace(CERTFD_PUB_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_PUB_DOC_CN,
trim(translate(replace(CERTFD_MOU_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_MOU_DOC_CN,
trim(translate(replace(CERTFD_CLIN_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_CLIN_DOC_CN,
trim(translate(replace(CERTFD_TRDN_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_TRDN_DOC_CN,
trim(translate(replace(CERTFD_ASS_PUB_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_ASS_PUB_DOC_CN,
trim(translate(replace(CERTFD_ASS_MOU_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_ASS_MOU_DOC_CN,
trim(translate(replace(CERTFD_ASS_CLIN_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_ASS_CLIN_DOC_CN,
trim(translate(replace(CERTFD_ASS_TRDN_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CERTFD_ASS_TRDN_DOC_CN,
trim(translate(replace(ICU_DOC_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ICU_DOC_CN,
trim(translate(replace(CLIN_NURSE_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CLIN_NURSE_CN,
trim(translate(replace(WARD_NURSE_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))WARD_NURSE_CN,
trim(translate(replace(ICU_NURSE_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ICU_NURSE_CN,
trim(translate(replace(SUBDISTRICT_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SUBDISTRICT_CN,
trim(translate(replace(COMM_SVR_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))COMM_SVR_CN,
trim(translate(replace(TOWN_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TOWN_CN,
trim(translate(replace(RESIDENT_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESIDENT_CN,
trim(translate(replace(SVR_COVER_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SVR_COVER_CN,
trim(translate(replace(SVR_CENTER_PLAN_ORG_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SVR_CENTER_PLAN_ORG_CN,
trim(translate(replace(SVR_CENTER_ORG_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SVR_CENTER_ORG_CN,
trim(translate(replace(SVR_PLAN_ORG_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SVR_PLAN_ORG_CN,
trim(translate(replace(SVR_ORG_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SVR_ORG_CN,
trim(translate(replace(EXE_PRICE_DIFF_SVR_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXE_PRICE_DIFF_SVR_CN,
trim(translate(replace(EXE_PRICE_DIFF_ORG_CN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXE_PRICE_DIFF_ORG_CN,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(ORG_TEL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_TEL_NO,
trim(translate(replace(ORG_CHARGE_PERSON_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CHARGE_PERSON_NAME,
trim(translate(replace(ORG_CHARGE_PERSON_TEL,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CHARGE_PERSON_TEL,
trim(translate(replace(ADDR_PROVINCE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_PROVINCE,
trim(translate(replace(ADDR_CITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_CITY,
trim(translate(replace(ADDR_COUNTY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_COUNTY,
trim(translate(replace(ADDR_TOWN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_TOWN,
trim(translate(replace(ADDR_VILLAGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_VILLAGE,
trim(translate(replace(ADDR_HOUSE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ADDR_HOUSE_NO,
trim(translate(replace(POSTAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))POSTAL_CODE    from  mid_base_resour_org_year"
delete_sql="delete from  wj_data.mid_base_resour_org_year"
select_sql="
select count(1)
  from wj_data.mid_base_resour_org_year";;

mid_base_svr_mdc_day) 
sql_str="
select
 dim_date                    , 
 org_code                    ,
 org_name                    ,
 dept_code                   ,
 dept_name                   ,
 reg_tele_cn                 ,
 reg_wx_cn                   ,
 reg_org_cn                  ,
 reg_web_cn                  ,
 reg_phone_cn                ,
 reg_mp_web_cn               ,
 reg_all_tp_total            ,
 op_count                    ,
 u_count                     ,
 op_fee                      ,
 op_med_fee                  ,
 ess_natn_fee                ,
 ess_prov_sup_fee            ,
 op_check_fee                ,
 op_test_fee                 ,
 out_count                   ,
 out_fee                     ,
 in_med_fee                  ,
 in_ess_natn_fee             ,
 in_ess_prov_sup_fee         ,
 in_check_fee                ,
 in_test_fee                 ,
 op_reg_fee                  ,
 op_inspect_fee              ,
 op_treatment_fee            ,
 op_oxy_fee                  ,
 op_operate_fee              ,
 op_western_med_fee          ,
 op_cn_patent_fee            ,
 op_cn_herbal_med_fee        ,
 op_narco_fee                ,
 op_narco_rela_fee           ,
 op_amb_fee                  ,
 op_oth_fee                  ,
 register_ordn_cn            ,
 register_vice_cn            ,
 register_chief_cn           ,
 register_expt_cn            ,
 register_emg_cn             ,
 register_oth_cn             ,
 in_inspect_fee              ,
 in_treatment_fee            ,
 in_oxy_fee                  ,
 in_operate_fee              ,
 in_western_med_fee          ,
 in_cn_patent_fee            ,
 in_cn_herbal_med_fee        ,
 in_narco_fee                ,
 in_narco_rela_fee           ,
 in_amb_fee                  ,
 in_tranfsn_fee              ,
 in_bed_fee                  ,
 in_nursing_fee              ,
 in_oth_fee                  ,
 into_count                  ,
 tran_in_cn                  ,
 tran_out_cn                 ,
 bein_count                  ,
 bein_critical_cn            ,
 critical_res_cn             ,
 critical_res_succ_cn        ,
 out_hos_dead_cn             ,
 op_xman_cn                  ,
 u_rescue_cn                 ,
 em_critical_res_cn          ,
 em_critical_res_succ_cn     ,
 icu_dead_cn                 ,
 operate_xman_cn             ,
 operate_cn                  ,
 operate_period_sum          ,
 confm_in_time_diff3_cn      ,
 diag_op_in_accord_cn        ,
 diag_op_in_non_accord_cn    ,
 diag_out_in_accord_cn       ,
 diag_out_in_non_accord_cn   ,
 operate_diag_accrod_cn      ,
 operate_diag_non_accrod_cn  ,
 revisit_cn                  ,
 mdc_accid_cn                ,
 in_better_count             ,
 in_dead_cn                  ,
 cure_cn                     ,
 operate_cure_cn             ,
 od_outin_cn                 ,
 out_non_dead_cn             ,
 out_haemorrhoid_cn          ,
 slt_operate_compct_cn       ,
 slt_operate_cn              ,
 operate_re_cn               ,
 operate_dead_cn             ,
 nc_dead_cn                  ,
 nb_out_cn                   ,
 medc_error_cn               ,
 med_var_use_cn              ,
 reserved_beds               ,
 rescue_total_times          ,
 rescue_cn                   ,
 drug_diff_times             ,
 drug_diff_blw3_times        ,
 consult_confirm_cn          ,
 consult_cn                  ,
 difficult_case_discus_cn    ,
 difficult_case_cn           ,
 narcosis_prev_cn            ,
 critical_nurse_qua_cn       ,
 clin_route_cn               ,
 infect_dis_rpt_cn           ,
 infect_dis_cn               ,
 difficult_critical_cn       ,
 re_into_15_cn               ,
 re_into_31_cn               ,
 iatrogenic_pne_cn           ,
 icu_lung_infec_cn           ,
 icu_cpap_cn                 ,
 operate_complication_cn     ,
 operate_embolism_cn         ,
 operate_blood_cn            ,
 operate_scd_cn              ,
 slt_operate_period_sum      ,
 med_var_herbal_use_cn       ,
 med_var_wes_use_cn          ,
 med_var_patent_use_cn       ,
 op_med_var_use_cn           ,
 in_med_var_use_cn           ,
 anti_var_use_count          ,
 anti_count                  ,
 anti_quantity               ,
 injec_var_use_count         ,
 injec_count                 ,
 injec_stc_count             ,
 ess_var_use_count           ,
 ess_count                   ,
 ess_prov_sup_var_cn         ,
 atvi_var_use_count          ,
 atvi_count                  ,
 revr_var_use_count          ,
 revr_count                  ,
 med_wes_stoc_fee            ,
 revr_fee                    ,
 atvi_fee                    ,
 anti_ddd_quantity           ,
 anti_fee                    ,
 no_case_his_count           ,
 quali_case_his_count        ,
 a_case_his_count            ,
 marco_pass_recipe_cn        ,
 marco_recipe_cn             ,
 id                          ,
 last_update_dtime           ,
 zoe_sys_client_code         ,
 zoe_sys_collect_time        
   from mid_base_svr_mdc_day  where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.mid_base_svr_mdc_day"
select_sql="
select count(1)
  from wj_data.mid_base_svr_mdc_day
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

oper_record)  
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(EVENT_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_TYPE,
trim(translate(replace(EVENT_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EVENT_NO,
trim(translate(replace(OPER_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPER_FORM_NO,
trim(translate(replace(AUTHOR_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_DTIME,
trim(translate(replace(AUTHOR_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_ID,
trim(translate(replace(AUTHOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))AUTHOR_NAME,
trim(translate(replace(SURGEON_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SURGEON_ID,
trim(translate(replace(SURGEON_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SURGEON_NAME,
trim(translate(replace(ASSISTANT1_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSISTANT1_ID,
trim(translate(replace(ASSISTANT1_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSISTANT1_NAME,
trim(translate(replace(ASSISTANT2_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSISTANT2_ID,
trim(translate(replace(ASSISTANT2_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSISTANT2_NAME,
trim(translate(replace(ANESTHESIOLOGIST_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANESTHESIOLOGIST_ID,
trim(translate(replace(ANESTHESIOLOGIST_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANESTHESIOLOGIST_NAME,
trim(translate(replace(OPERATION_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_DTIME,
trim(translate(replace(PRE_DIAGNOSIS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRE_DIAGNOSIS,
trim(translate(replace(MID_DIAGNOSIS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MID_DIAGNOSIS,
trim(translate(replace(OPERATION_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_NAME,
trim(translate(replace(OPERATION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_CODE,
trim(translate(replace(OPERATION_SITE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_SITE_CODE,
trim(translate(replace(OPERATION_SITE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_SITE_NAME,
trim(translate(replace(ANESTHESIA_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANESTHESIA_CODE,
trim(translate(replace(INCISION_HEALING_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INCISION_HEALING_CODE,
trim(translate(replace(OPERATION_COURSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_COURSE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(OPERATION_END_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_END_TIME,
trim(translate(replace(INTERVENTION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INTERVENTION,
trim(translate(replace(OP_POSITION_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_POSITION_CODE,
trim(translate(replace(OPERATION_DESCRIBE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_DESCRIBE,
trim(translate(replace(SKIN_THIMEROSAL,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SKIN_THIMEROSAL,
trim(translate(replace(WOUND_DESCR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))WOUND_DESCR,
trim(translate(replace(WOUND_CLASS_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))WOUND_CLASS_CODE,
trim(translate(replace(DRAIN_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRAIN_FLAG,
trim(translate(replace(OPERATION_BLEED_AMOUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATION_BLEED_AMOUNT,
trim(translate(replace(INFUSION_AMOUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INFUSION_AMOUNT,
trim(translate(replace(TRANSFUSION_AMOUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TRANSFUSION_AMOUNT,
trim(translate(replace(OP_PRE_DRUG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_PRE_DRUG,
trim(translate(replace(OP_DRUG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OP_DRUG,
trim(translate(replace(DRAIN_MATERIAL_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRAIN_MATERIAL_NAME,
trim(translate(replace(DRAIN_MATERIAL_AMOUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRAIN_MATERIAL_AMOUNT,
trim(translate(replace(PLACED_PART,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PLACED_PART,
trim(translate(replace(TRANSFUSE_REACTION_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TRANSFUSE_REACTION_FLAG,
trim(translate(replace(DEVICE_NURSE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEVICE_NURSE_NAME,
trim(translate(replace(TOUR_NURSE_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TOUR_NURSE_NAME    from  oper_record
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.oper_record  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.oper_record
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

outpatient)   
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(VISIT_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_ORG_NAME,
trim(translate(replace(VISIT_ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_ORG_CODE,
trim(translate(replace(VISIT_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_DEPT_NAME,
trim(translate(replace(VISIT_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_DTIME,
trim(translate(replace(REFERRAL_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERRAL_MARK,
trim(translate(replace(HEALTH_SERVICE_DEMAND,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_SERVICE_DEMAND,
trim(translate(replace(HEALTH_PROBLEM_EVAL,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_PROBLEM_EVAL,
trim(translate(replace(TREATMENT_PLAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREATMENT_PLAN,
trim(translate(replace(OTHER_MEDICAL_TREATMENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OTHER_MEDICAL_TREATMENT,
trim(translate(replace(RESP_DOCTOR_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RESP_DOCTOR_NAME,
trim(translate(replace(SBP,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SBP,
trim(translate(replace(DBP,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DBP,
trim(translate(replace(DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEPT_CODE,
trim(translate(replace(DOCTOR_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DOCTOR_CODE,
trim(translate(replace(DOCTOR_TITLE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DOCTOR_TITLE_CODE,
trim(translate(replace(REG_TYPE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REG_TYPE,
trim(translate(replace(SEC_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEC_TYPE_CODE,
trim(translate(replace(SEC_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEC_NO,
trim(translate(replace(IS_LOCAL_MARK,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))IS_LOCAL_MARK,
trim(translate(replace(STD_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))STD_DEPT_CODE,
trim(translate(replace(CONSULT_QUESTION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CONSULT_QUESTION,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(VISIT_FIRST_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VISIT_FIRST_FLAG,
trim(translate(replace(VALID_TIME_NUM,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))VALID_TIME_NUM     from outpatient
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.outpatient  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.outpatient
 where LAST_UPDATE_DTIME  like '${file_date}%'";;
  
outpatient_diag)   
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(DIAGNOSIS_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAGNOSIS_ID,
trim(translate(replace(OUTPAT_DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_DIAG_NAME,
trim(translate(replace(OUTPAT_DIAG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_DIAG_CODE,
trim(translate(replace(DIAG_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_DATE,
trim(translate(replace(DIAG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_TYPE_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(INFECT_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INFECT_FLAG,
trim(translate(replace(INFECT_REPORT_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INFECT_REPORT_FLAG  from outpatient_diag
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.outpatient_diag  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.outpatient_diag
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

outpatient_drug)   
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(CN_MEDICINE_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CN_MEDICINE_TYPE_CODE,
trim(translate(replace(DRUG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_NAME,
trim(translate(replace(DRUG_FORM_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_FORM_CODE,
trim(translate(replace(DRUG_USING_DAYS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_USING_DAYS,
trim(translate(replace(DRUG_USING_FREQ,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_USING_FREQ,
trim(translate(replace(DRUG_DOSE_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_DOSE_UNIT,
trim(translate(replace(DRUG_PER_DOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_PER_DOSE,
trim(translate(replace(DRUG_TOTAL_DOSE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_TOTAL_DOSE,
trim(translate(replace(DRUG_ROUTE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_ROUTE_CODE,
trim(translate(replace(DRUG_STOP_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_STOP_DTIME,
trim(translate(replace(DRUG_LOCAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_LOCAL_CODE,
trim(translate(replace(DRUG_STD_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_STD_NAME,
trim(translate(replace(DRUG_STD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_STD_CODE,
trim(translate(replace(DRUG_TOTAL_UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_TOTAL_UNIT,
trim(translate(replace(SPEC,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPEC,
trim(translate(replace(GROUP_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))GROUP_NO,
trim(translate(replace(DRUG_START_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_START_DTIME,
trim(translate(replace(DISPENSING_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DISPENSING_DTIME,
trim(translate(replace(NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NOTES,
trim(translate(replace(DRUG_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_TYPE_CODE,
trim(translate(replace(DDD_VALUE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DDD_VALUE,
trim(translate(replace(ANTIBACTERIAL_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ANTIBACTERIAL_FLAG,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(CRUCIAL_DRUG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CRUCIAL_DRUG_NAME,
trim(translate(replace(CRUCIAL_DRUG_USAGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CRUCIAL_DRUG_USAGE,
trim(translate(replace(PRESCRIBE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRESCRIBE_NO,
trim(translate(replace(DRUG_ADVERSE_REACTION,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DRUG_ADVERSE_REACTION  from outpatient_drug
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.outpatient_drug  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.outpatient_drug
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

outpatient_fee)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ID,
trim(translate(replace(OUTPAT_FEE_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FEE_TYPE_CODE,
trim(translate(replace(OUTPAT_FEE_AMOUNT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FEE_AMOUNT,
trim(translate(replace(PAY_WAY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAY_WAY_CODE,
trim(translate(replace(OUTPAT_SETTLE_WAY_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_SETTLE_WAY_CODE,
trim(translate(replace(PRICE_ITEM_LOCAL_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE_ITEM_LOCAL_CODE,
trim(translate(replace(PRICE_ITEM_STD_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE_ITEM_STD_CODE,
trim(translate(replace(DEDUCT_FEES_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DEDUCT_FEES_DTIME,
trim(translate(replace(SPEC,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SPEC,
trim(translate(replace(UNIT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))UNIT,
trim(translate(replace(PRICE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE,
trim(translate(replace(QUANTITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))QUANTITY,
trim(translate(replace(NOTES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NOTES,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(PRICE_ITEM_LOCAL_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PRICE_ITEM_LOCAL_NAME,
trim(translate(replace(SELF_PAYMENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SELF_PAYMENT,
trim(translate(replace(APPLY_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT_CODE,
trim(translate(replace(APPLY_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DEPT_NAME,
trim(translate(replace(APPLY_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))APPLY_DOCTOR,
trim(translate(replace(EXEC_DEPT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXEC_DEPT_CODE,
trim(translate(replace(EXEC_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXEC_DEPT_NAME,
trim(translate(replace(EXEC_MAN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))EXEC_MAN,
trim(translate(replace(CHARGES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHARGES,
trim(translate(replace(INSURANCE_CHARGES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INSURANCE_CHARGES,
trim(translate(replace(DERATE_CHARGES,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DERATE_CHARGES,
trim(translate(replace(OPERATOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OPERATOR,
trim(translate(replace(BABAY_FLAG,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BABAY_FLAG        from outpatient_fee
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.outpatient_fee  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.outpatient_fee
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

outpatient_symp)   
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(SYMPTOM_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMPTOM_ID,
trim(translate(replace(SYMPTOM_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMPTOM_NAME,
trim(translate(replace(SYMPTOM_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMPTOM_CODE,
trim(translate(replace(ONSET_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ONSET_DTIME,
trim(translate(replace(SYMP_DURATION_MINS,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SYMP_DURATION_MINS,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME from outpatient_symp
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.outpatient_symp  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.outpatient_symp
 where LAST_UPDATE_DTIME  like '${file_date}%'";;

referinfo)    
sql_str="
select
trim(translate(replace(LAST_UPDATE_DTIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))LAST_UPDATE_DTIME,
trim(translate(replace(ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ORG_CODE,
trim(translate(replace(PATIENT_ID,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PATIENT_ID,
trim(translate(replace(CHANGE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CHANGE_NO,
trim(translate(replace(HEALTH_RECORD_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_RECORD_NO,
trim(translate(replace(RECORD_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RECORD_DATE,
trim(translate(replace(NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))NAME,
trim(translate(replace(SEX_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))SEX_CODE,
trim(translate(replace(BIRTH_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))BIRTH_DATE,
trim(translate(replace(HOME_ADDR_PROVINCE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HOME_ADDR_PROVINCE,
trim(translate(replace(HOME_ADDR_CITY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HOME_ADDR_CITY,
trim(translate(replace(HOME_ADDR_COUNTY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HOME_ADDR_COUNTY,
trim(translate(replace(HOME_ADDR_TOWN,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HOME_ADDR_TOWN,
trim(translate(replace(HOME_ADDR_VILLAGE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HOME_ADDR_VILLAGE,
trim(translate(replace(HOME_ADDR_HOUSE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HOME_ADDR_HOUSE_NO,
trim(translate(replace(REFERRAL_PAT_TEL_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERRAL_PAT_TEL_NO,
trim(translate(replace(PAST_DISEASE_HISTORY,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAST_DISEASE_HISTORY,
trim(translate(replace(PAST_DISEASE_TYPE_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))PAST_DISEASE_TYPE_CODE,
trim(translate(replace(ZOE_SYS_CLIENT_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_CLIENT_CODE,
trim(translate(replace(ZOE_SYS_COLLECT_TIME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ZOE_SYS_COLLECT_TIME,
trim(translate(replace(REFERTO_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERTO_ORG_NAME,
trim(translate(replace(REFERTO_ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERTO_ORG_CODE,
trim(translate(replace(REFERTO_DEPT_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERTO_DEPT_NAME,
trim(translate(replace(REFERTO_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERTO_DOCTOR,
trim(translate(replace(TRANSFER_DOCTOR,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TRANSFER_DOCTOR,
trim(translate(replace(REFERTO_DOCTOR_TEL,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERTO_DOCTOR_TEL,
trim(translate(replace(REFERFROM_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERFROM_ORG_NAME,
trim(translate(replace(REFERFROM_ORG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERFROM_ORG_CODE,
trim(translate(replace(OUTPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OUTPAT_FORM_NO,
trim(translate(replace(INPAT_FORM_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))INPAT_FORM_NO,
trim(translate(replace(REFERRAL_REASON,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))REFERRAL_REASON,
trim(translate(replace(OTHER_MEDICAL_TREATMENT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))OTHER_MEDICAL_TREATMENT,
trim(translate(replace(CASE_NO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))CASE_NO,
trim(translate(replace(TREATMENT_PROPOSAL,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TREATMENT_PROPOSAL,
trim(translate(replace(MENTAL_REHAB_MEANS_GUIDE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MENTAL_REHAB_MEANS_GUIDE,
trim(translate(replace(TRANSFER_INFO,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))TRANSFER_INFO,
trim(translate(replace(DIAG_CODE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_CODE,
trim(translate(replace(DIAG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_NAME,
trim(translate(replace(DIAG_DATE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_DATE,
trim(translate(replace(DIAG_ORG_NAME,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))DIAG_ORG_NAME,
trim(translate(replace(RELATED_SYMPTOM,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))RELATED_SYMPTOM,
trim(translate(replace(MAIN_TREATMENT_MEASURE,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))MAIN_TREATMENT_MEASURE,
trim(translate(replace(ASSIST_EXAM_RESULT,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))ASSIST_EXAM_RESULT,
trim(translate(replace(HEALTH_PROBLEM_EVAL,'\','/'),chr(13)||chr(10)||chr(0)||'$',','))HEALTH_PROBLEM_EVAL    from referinfo
 where LAST_UPDATE_DTIME  like '${file_date}%'"
delete_sql="delete from  wj_data.referinfo  where LAST_UPDATE_DTIME  like '${file_date}%'"
select_sql="
select count(1)
  from wj_data.referinfo
 where LAST_UPDATE_DTIME  like '${file_date}%'";;  
esac
