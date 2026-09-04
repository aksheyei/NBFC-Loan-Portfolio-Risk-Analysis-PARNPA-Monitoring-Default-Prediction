CREATE DATABASE NBFC;
use NBFC;

-- -------------------------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING
-- --------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------
-- CUSTOMER TABLE
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Casing all columns into lowercase for easy access
alter table customers
rename column Customer_ID to customer_id,
rename column Age to age,
rename column Gender to gender,
rename column Employment_Type to employment_type,
rename column Monthly_Income to monthly_income,
rename column CIBIL_Score to cibil_score,
rename column State to state;

desc customers;
select * from customers;

-- removing the rows were age is less than 18 and 80 (removing outliers)
delete from customers
where age <18 or age>80;

-- making the values inside having into same category example male female m f etc

update customers
set gender = 'Male'
where lower(gender) in ('male','m');

update customers
set gender = 'Female'
where lower(gender) in ('female','f');

update customers
set gender = 'Male'
where lower(gender)='N/A';

-- correcting the inconsistent spellings
update customers
set employment_type ='Salaried'
where trim(lower(employment_type)) ='salaried';

update customers
set employment_type ='Self Employed'
where trim(lower(employment_type)) in('self-employed','self employed','selfemployed','N/A');

-- removing the cibil score which less than 300 and above 900

delete from customers
where cibil_score >900 or cibil_score <300;

-- making spellings into consistent spelling in state
update customers
set state ='Kerala'
where trim(lower(state)) in ('kerala','keral');

update customers
set state ='Tamil Nadu'
where trim(lower(state)) in ('tamil nadu','tn','tamilnadu');

update customers
set state ='Telangana'
where trim(lower(state)) = 'telangana';

update customers
set state ='Maharashtra'
where trim(lower(state)) in ('mh','maharashtra','Maharastra');

update customers
set state ='West Bengal'
where trim(lower(state)) in('westbengal','wb','west bengal');

update customers
set state ='Andra Pradesh'
where trim(lower(state)) in('andra pradesh','ap','andhra pradesh');

update customers
set state ='Delhi'
where trim(lower(state)) = 'new delhi';

update customers
set state ='Karnataka'
where trim(lower(state)) in('karnatka','karnataka');

update customers
set state ='Uttar Pradesh'
where trim(lower(state)) in ('uttar pradesh','up');

update customers
set state ='Gujarat'
where trim(lower(state)) in('gujarat','gujrat','gj');


select distinct monthly_income from customers
order by monthly_income asc;

-- replaceing the additional characters inside monthly_income
UPDATE customers
SET monthly_income = REPLACE(REPLACE(monthly_income, 'â‚¹', ''), ',', '');

-- removing monthly_income which is less than 0
delete from customers
where monthly_income <=0;

-- changing the monthly_income text into int data type
alter table customers
modify monthly_income int;

select * from  customers;

-- ---------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- LOANS TABLE
-- ----------------------------------------------------------------------------------------------------------------------------------------
desc loans;
-- changing the columns name into lower case

alter table loans
rename column Loan_ID to loan_id,
rename column Customer_ID to customer_id,
rename column Disbursal_Date to disbursal_date,
rename column Loan_Amount to loan_amount,
rename column Tenure_Months to tenure_months,
rename column Interest_Rate to interest_rate,
rename column EMI_Amount to emi_amount,
rename column Vehicle_Type to vehicle_type,
rename column Branch to branch;

-- replaceing the additional characters inside loan_amount
UPDATE loans
SET loan_amount = REPLACE(REPLACE(loan_amount, 'â‚¹', ''), ',', '');

-- removing loan_amount which is less than 0
delete from loans
where loan_amount <=0;

-- changing the text data type into int
alter table loans
modify loan_amount int;

-- making the consistent of spelling 

update loans
set vehicle_type='Two wheeler'
where trim(lower(vehicle_type)) in ('two wheeler','two-wheeler','2 wheeler');

update loans
set vehicle_type='Car'
where trim(lower(vehicle_type))  ='car';

update loans
set vehicle_type='Tractor'
where trim(lower(vehicle_type))  ='tractor';

update loans
set vehicle_type='Commercial Vehicle'
where trim(lower(vehicle_type)) in ('Commercial  Vehicle','cv');

update loans
set vehicle_type ='Car'
where trim(lower(vehicle_type)) ='N/A';

select distinct branch from loans;

update loans
set branch='delhi'
where branch ='delhi ncr';

update loans
set branch=trim(lower(branch));

select * from loans;

-- -----------------------------------------------------------------------------------------------------------------------------------------

-- REPAYMENT_HISTORY TABLE
-- --------------------------------------------------------------------------------------------------------------------------------------

desc repayment_history;

-- converting the column names into lower case
ALTER TABLE repayment_history
RENAME COLUMN Loan_ID TO loan_id,
RENAME COLUMN Month_Number TO month_number,
RENAME COLUMN Due_Date TO due_date,
RENAME COLUMN EMI_Due TO emi_due,
RENAME COLUMN EMI_Paid TO emi_paid,
RENAME COLUMN Payment_Date TO payment_date,
RENAME COLUMN Days_Late TO days_late;


-- replaceing the additional characters inside emi_due
UPDATE repayment_history
SET emi_due = REPLACE(REPLACE(emi_due, 'â‚¹', ''), ',', '');

-- removing emi_due which is less than 0
delete from repayment_history
where emi_due <=0;

-- PRIMARY DATA CLEANING COMPLETED
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------




