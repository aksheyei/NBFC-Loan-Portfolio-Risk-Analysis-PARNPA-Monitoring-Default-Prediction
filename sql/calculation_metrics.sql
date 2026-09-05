SELECT * FROM customers
LIMIT 20;
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- CALCULATING THE BASIC METRICS
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- COUNT OF UNIQUE CUSTOMERS
SELECT COUNT(customer_id) AS total_customers
FROM customers;
-- COUNT OF GENDER WISE CUSTOMERS
SELECT 
	gender,
	COUNT(customer_id) AS total_customers
FROM customers
GROUP BY gender;

-- COUNT OF CUSTOMERS IN EMPLOYMENT_TYPE WISE
SELECT 
	employment_type,
	COUNT(customer_id) AS total_customers
FROM customers
GROUP BY employment_type;

-- COUNT OF CUSTOMERS IN STATE WISE
SELECT 
	state,
	COUNT(customer_id) AS total_customers
FROM customers
GROUP BY state;

-- MINIMUM AND MAXIMUM MONTHLY_INCOME OF CUSTOMER
SELECT 
	MIN(monthly_income) AS Min_income,
    MAX(monthly_income) AS Max_income
FROM customers;

-- MINIMUM AND MAXIMUM AGE OF CUSTOMERS
SELECT 
	MIN(age) AS Min_age,
    MAX(age) AS Max_age
FROM customers;

-- CREATING AGE BUCKET CATEGORY
ALTER TABLE customers
MODIFY COLUMN age_bucket VARCHAR(20);

UPDATE customers
SET age_bucket = CASE 
				WHEN age <=30 THEN '21-30'
                WHEN age <=40 THEN '31-40'
                WHEN age <=50 THEN '41-50'
                WHEN age <=60 THEN '51-60'
                ELSE '60 Above'
                END;
			
SELECT * FROM loans;
-- TOTAL LOANS PROVIDED
SELECT COUNT(loan_id) AS total_loans
FROM loans;

-- TOTAL LOAN AMOUNT
SELECT 
	SUM(loan_amount) AS total_loan_amount
FROM loans;
-- TOTAL LOAN AMOUNT BY VEHICLE_TYPE
SELECT 
	vehicle_type,
	SUM(loan_amount) AS total_loan_amount
FROM loans
GROUP BY vehicle_type;

-- TOTAL LOAN AMOUNT BY BRANCH
SELECT 
	branch,
	SUM(loan_amount) AS total_loan_amount
FROM loans
GROUP BY branch;

SELECT * FROM repayment_history;

-- TOTAL NUMBERS OF ROWS
SELECT 
	COUNT(*) AS total_rows
FROM repayment_history;

-- MINIMUM AND MAXIMUM DAY_LATES
SELECT 	
	MIN(days_late) AS Min_day_late,
	MAX(days_late) AS Max_day_late
FROM repayment_history;

-- TOTAL EMI_PAID
SELECT 
	ROUND(SUM(emi_paid),2) AS total_emi_paid
FROM repayment_history;


