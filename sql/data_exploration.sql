use NBFC;

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- DATA EXPLORATION
-- -------------------------------------------------------------------------------------------------------------------------------------------
SHOW TABLES;
-- CUSTOMER TABLE 

SELECT * FROM customers
LIMIT 20;

-- UNIQUE GENDER CATEGORY
SELECT DISTINCT gender 
FROM customers;

-- UNIQUE EMPLOYMENT_TYPE CATEGORY
SELECT DISTINCT employment_type 
FROM customers;

-- UNIQUE STATE CATEGORY
SELECT DISTINCT state 
FROM customers;

-- LOANS TABLE
SELECT * FROM loans
LIMIT 20;

-- LOANS TABLE
SELECT * FROM loans
LIMIT 20;

-- UNIQUE VEHICLE_TYPE
SELECT DISTINCT vehicle_type
FROM loans;
-- UNIQUE BRANCH
SELECT DISTINCT branch
FROM loans;

-- REPAYMENT_HISTORY
SELECT * FROM repayment_history
LIMIT 20;




