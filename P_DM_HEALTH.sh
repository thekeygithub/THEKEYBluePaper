个人主索引：
CREATE TABLE wj_data.emp_1 as select a.last_update_dtime,a.org_code,a.patient_id,a.outpat_form_no,a.VISIT_DEPT_NAME,a.VISIT_DTIME,a.REFERRAL_MARK,b.DRUG_TYPE_CODE,b.DRUG_LOCAL_CODE,b.DRUG_NAME,b.DRUG_FORM_CODE,c.OUTPAT_FEE_TYPE_CODE ,c.OUTPAT_FEE_AMOUNT,c.PAY_WAY_CODE,c.PRICE_ITEM_LOCAL_CODE,c.PRICE_ITEM_LOCAL_NAME,c.APPLY_DEPT_CODE,c.APPLY_DEPT_NAME,c.APPLY_DOCTOR,c.CHARGES,c.INSURANCE_CHARGES from Outpatient a left join  Outpatient_Drug b on a.OUTPAT_FORM_NO=b.OUTPAT_FORM_NO left join Outpatient_Fee c on a.OUTPAT_FORM_NO=c.OUTPAT_FORM_NO ;
 
 CREATE TABLE wj_data.emp_1end as select  a.*,d.OUTPAT_DIAG_NAME ,d.OUTPAT_DIAG_CODE ,d.DIAG_DATE,
e.SYMPTOM_ID,e.SYMPTOM_NAME,e.SYMPTOM_CODE,
f.change_no,f.referfrom_org_name,f.referfrom_org_code,f.referfrom_dept_name,
f.referto_org_name,f.referto_org_code,f.referto_dept_name ,f.referral_records,
f.referral_date ,f.referral_reason ,f.treatment_proposal
from emp_1 a  left join Outpatient_Diag d on a.OUTPAT_FORM_NO=d.OUTPAT_FORM_NO left join Outpatient_Symp e on a.OUTPAT_FORM_NO=e.OUTPAT_FORM_NO left join Outpatient_Referral f on a.OUTPAT_FORM_NO=f.OUTPAT_FORM_NO 

CREATE TABLE wj_data.emp_2 as select a.last_update_dtime,a.org_code,a.patient_id,a.inpat_form_no,a.in_dept_name,a.in_dtime,a.REFERRAL_MARK,b.DRUG_TYPE_CODE,b.DRUG_LOCAL_CODE,b.DRUG_NAME,b.DRUG_FORM_CODE from INpatient a left join  inpatient_Drug b on a.inPAT_FORM_NO=b.inPAT_FORM_NO left join inpatient_Fee c on a.inPAT_FORM_NO=c.inPAT_FORM_NO ;
 
insert into emp_21 select  a.*, c.INPAT_FEE_TYPE_CODE ,
c.INPAT_FEE_AMOUNT,c.PAY_WAY_CODE,c.PRICE_ITEM_LOCAL_CODE,c.PRICE_ITEM_LOCAL_NAME,c.APPLY_DEPT_CODE,c.APPLY_DEPT_NAME,c.APPLY_DOCTOR,c.CHARGES,c.INSURANCE_CHARGES from emp_2 a left join inpatient_Fee c on a.inPAT_FORM_NO=c.inPAT_FORM_NO;

CREATE TABLE wj_data.emp_22 as select a.*,
d.IN_DIAG_NAME ,d.IN_DIAG_CODE ,d.CONFIRMED_DIAG_DATE,
e.SYMPTOM_ID,e.SYMPTOM_NAME,e.SYMPTOM_CODE
from emp_21 a left join inpatient_INDiag d on a.inPAT_FORM_NO=d.inPAT_FORM_NO 
  left join INpatient_Symp e on a.INPAT_FORM_NO=e.INPAT_FORM_NO 
  
CREATE TABLE wj_data.emp_2end as select a.*,
f.change_no,f.referfrom_org_name,f.referfrom_org_code,f.referfrom_dept_name,
f.referto_org_name,f.referto_org_code,f.referto_dept_name ,f.referral_records,
f.referral_date ,f.referral_reason ,f.treatment_proposal
from emp_22 a left join INpatient_Referral f on a.INPAT_FORM_NO=f.INPAT_FORM_NO 
    
insert into wj_dm.empi_1111(last_update_dtime,org_code,patient_id,outpat_form_no,in_dept_name,
in_dtime,referral_mark,drug_type_code,drug_local_code,drug_name,drug_form_code,
outpat_fee_type_code,outpat_fee_amount,pay_way_code,price_item_local_code,
price_item_local_name,apply_dept_code,apply_dept_name,apply_doctor,charges,
insurance_charges,outpat_diag_name,outpat_diag_code,
diag_date,symptom_id,symptom_name,symptom_code,change_no,
referfrom_org_name,referfrom_org_code,referfrom_dept_name,referto_org_name,
referto_org_code,referto_dept_name,referral_records,referral_date,referral_reason,
treatment_proposal) 

select * from wj_data.emp_1end 
 union all
select * from wj_data.emp_2end;
医疗机构主索引：
create table empi_h as 
 select distinct a.org_code,b.visit_org_name  
 from wj_data.baseinfo a join wj_data1.original_code b on trim(a.org_code)=trim(b.org_code);

 create table emp_h1 as    
  select  org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(distinct patient_id)
  from wj_data.Outpatient group by org_code ,substr(LAST_UPDATE_DTIME,1,7);
  
 create table emp_h2 as    
  select  org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  sum(case when OUTPAT_FEE_AMOUNT='' then 0 else cast(OUTPAT_FEE_AMOUNT as float) end)OUTPAT_FEE_AMOUNT ,
  sum(case when SELF_PAYMENT='' then 0 else cast(SELF_PAYMENT as float) end)SELF_PAYMENT,
  sum(case when CHARGES='' then 0 else cast(CHARGES as float) end)CHARGES ,
  sum(case when INSURANCE_CHARGES='' then 0 else cast(INSURANCE_CHARGES  as float) end)INSURANCE_CHARGES,
  sum(case when DERATE_CHARGES='' then 0 else cast(DERATE_CHARGES as float) end)DERATE_CHARGES
  from wj_data.Outpatient_Fee group by org_code ,substr(LAST_UPDATE_DTIME,1,7);
  
   create table emp_h3 as    
  select  org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(distinct patient_id)
  from wj_data.Inpatient group by org_code ,substr(LAST_UPDATE_DTIME,1,7);
  
   create table emp_h4 as    
  select  org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  sum(case when INPAT_FEE_AMOUNT='' then 0 else cast(INPAT_FEE_AMOUNT as float) end)INPAT_FEE_AMOUNT ,
  sum(case when SELF_PAYMENT='' then 0 else cast(SELF_PAYMENT as float) end)SELF_PAYMENT,
  sum(case when CHARGES='' then 0 else cast(CHARGES as float) end)CHARGES ,
  sum(case when INSURANCE_CHARGES='' then 0 else cast(INSURANCE_CHARGES  as float) end)INSURANCE_CHARGES,
    sum(case when DERATE_CHARGES='' then 0 else cast(DERATE_CHARGES as float) end)DERATE_CHARGES
  from wj_data.Inpatient_Fee group by org_code ,substr(LAST_UPDATE_DTIME,1,7);
  
  create table emp_h5 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.Inpatient_Referral group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
  create table emp_h6 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.Outpatient_Referral group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
    create table emp_h7 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.Oper_Record group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
    create table emp_h8 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.  group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
      create table emp_h9 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.HealthExam_Reg  group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
   create table emp_h10 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.EDS_OUTPAT_MEDICAL_RECORD  group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
create table emp_h11 as 
  select org_code,    
  substr(LAST_UPDATE_DTIME,1,7),
  count(*)
  from wj_data.EDS_EM_OBSERVATION_MED_RECORD  group by org_code,    
  substr(LAST_UPDATE_DTIME,1,7);
  
  create table empi_hospital as
  select 
  a.nextval as empi,a.org_code,a.visit_org_name,b.substr as LAST_UPDATE_DTIME,b.count out_count,c.count in_count,
  d.OUTPAT_FEE_AMOUNT,d.SELF_PAYMENT,d.CHARGES,d.INSURANCE_CHARGES,d.DERATE_CHARGES,
  e.INPAT_FEE_AMOUNT,e.SELF_PAYMENT SELF_PAYMENT_1,e.CHARGES CHARGES_1,e.INSURANCE_CHARGES INSURANCE_CHARGES_1,
  e.DERATE_CHARGES DERATE_CHARGES_1,f.count Inpatient_Referral,g.count Outpatient_Referral ,h.count Oper,j.count ExamMaster,
  i.count HealthExam_Reg,p.count  eds_count,q.count eds_count1
  from emp_o a 
  left join emp_h1 b on a.org_code=b.org_code  
  left join emp_h3 c on a.org_code=c.org_code  and b.substr=c.substr
  left join emp_h2 d on a.org_code=d.org_code  and b.substr=d.substr
  left join emp_h4 e on a.org_code=e.org_code  and b.substr=e.substr
  left join emp_h5 f on a.org_code=f.org_code  and b.substr=f.substr
  left join emp_h6 g on a.org_code=g.org_code  and b.substr=g.substr
  left join emp_h7 h on a.org_code=h.org_code  and b.substr=h.substr
  left join emp_h8 j on a.org_code=j.org_code  and b.substr=j.substr
  left join emp_h9 i on a.org_code=i.org_code  and b.substr=i.substr
  left join emp_h10 p on a.org_code=p.org_code  and b.substr=p.substr
  left join emp_h11 q on a.org_code=q.org_code  and b.substr=q.substr
  group by  a.nextval,a.org_code,a.visit_org_name,b.substr,b.count,c.count,
d.OUTPAT_FEE_AMOUNT,d.SELF_PAYMENT,d.CHARGES,d.INSURANCE_CHARGES,d.DERATE_CHARGES,e.INPAT_FEE_AMOUNT,e.SELF_PAYMENT,e.CHARGES,e.INSURANCE_CHARGES,e.DERATE_CHARGES,f.count,g.count,h.count,j.count,i.count,p.count,q.count;
