/* ============================================================
   VEHICLE LOAN NBFC — PORTFOLIO & DELINQUENCY ANALYSIS
   Data Analyst: SQL Query Bank
   Tables: customers, loans, repayment_history
   ============================================================ */


/* A single loan-level "risk" view joining loans to their repayment behavior.
   Two separate flags, matching standard NBFC risk vocabulary:
     - is_npa            : DPD90+ on any installment (RBI-style NPA definition)
     - is_delinquent      : at least one due installment was never paid at all
                            (broader early-warning flag, includes partial/soft delays) */
DROP VIEW IF EXISTS loan_risk;
CREATE VIEW loan_risk AS
SELECT
    l.loan_id,
    l.customer_id,
    l.branch,
    l.vehicle_type,
    l.loan_amount,
    l.tenure_months,
    l.interest_rate,
    l.emi_amount,
    l.disbursal_date,
    cc.cibil_score,
    cc.employment_type,
    cc.monthly_income,
    cc.state,
    cc.age,
    cc.gender,
    COUNT(r.month_number)                                   AS installments_due,
    SUM(CASE WHEN r.payment_date IS NULL THEN 1 ELSE 0 END) AS installments_unpaid,
    SUM(CASE WHEN r.days_late > 0 THEN 1 ELSE 0 END)        AS installments_late,
    MAX(r.days_late)                                        AS max_days_late,
    ROUND(SUM(r.emi_paid) * 1.0 / NULLIF(SUM(r.emi_due),0), 4) AS collection_efficiency,
    CASE WHEN MAX(r.days_late) > 90 THEN 1 ELSE 0 END        AS is_npa,
    CASE WHEN SUM(CASE WHEN r.payment_date IS NULL THEN 1 ELSE 0 END) > 0
         THEN 1 ELSE 0 END                                  AS is_delinquent
FROM loans l
JOIN customers cc ON cc.customer_id = l.customer_id
LEFT JOIN repayment_history r ON r.loan_id = l.loan_id
GROUP BY 
	l.loan_id,
    l.customer_id,
    l.branch,
    l.vehicle_type,
    l.loan_amount,
    l.tenure_months,
    l.interest_rate,
    l.emi_amount,
    l.disbursal_date,
    cc.cibil_score,
    cc.employment_type,
    cc.monthly_income,
    cc.state,
    cc.age,
    cc.gender;

SELECT * FROM loan_risk;
/* ============================================================
   Q1. PORTFOLIO OVERVIEW — headline KPIs for the leadership tile
   ============================================================ */
SELECT
    COUNT(*)                           AS total_loans,
    ROUND(SUM(loan_amount),0)          AS total_disbursed_value,
    ROUND(AVG(loan_amount),0)          AS avg_loan_amount,
    ROUND(AVG(interest_rate),2)        AS avg_interest_rate,
    ROUND(AVG(tenure_months),1)        AS avg_tenure_months
FROM loans;


/* ============================================================
   Q2. MONTHLY DISBURSAL TREND — volume & value over time
   ============================================================ */
SELECT
    date_format(disbursal_date,'%Y-%m' ) AS month,
    COUNT(*)                          AS loans_disbursed,
    ROUND(SUM(loan_amount),0)         AS amount_disbursed
FROM loans
GROUP BY month
ORDER BY month;


/* ============================================================
   Q3. PORTFOLIO MIX BY VEHICLE TYPE — count, value, avg ticket size
   ============================================================ */
SELECT
    vehicle_type,
    COUNT(*)                    AS loan_count,
    ROUND(SUM(loan_amount),0)   AS total_value,
    ROUND(AVG(loan_amount),0)   AS avg_loan_amount,
    ROUND(AVG(interest_rate),2) AS avg_interest_rate
FROM loans
GROUP BY vehicle_type
ORDER BY total_value DESC;


/* ============================================================
   Q4. BRANCH PERFORMANCE — disbursal volume vs NPA rate
   ============================================================ */
SELECT
    branch,
    COUNT(*)                                            AS total_loans,
    ROUND(SUM(loan_amount),0)                           AS total_disbursed,
    SUM(is_npa)                                          AS npa_loans,
    ROUND(100.0 * SUM(is_npa) / COUNT(*), 2)             AS npa_rate_pct,
    ROUND(100.0 * SUM(is_delinquent) / COUNT(*), 2)      AS delinquency_rate_pct,
    ROUND(AVG(collection_efficiency)*100, 2)             AS avg_collection_efficiency_pct
FROM loan_risk
GROUP BY branch
ORDER BY npa_rate_pct DESC;


/* ============================================================
   Q5. CREDIT RISK BY CIBIL SCORE BAND — does score predict default?
   ============================================================ */
SELECT
    CASE
        WHEN cibil_score < 600 THEN '1. <600 (Poor)'
        WHEN cibil_score < 700 THEN '2. 600-699 (Fair)'
        WHEN cibil_score < 750 THEN '3. 700-749 (Good)'
        WHEN cibil_score < 800 THEN '4. 750-799 (Very Good)'
        ELSE '5. 800+ (Excellent)'
    END                                        AS cibil_band,
    COUNT(*)                                   AS total_loans,
    SUM(is_npa)                                AS npa_loans,
    ROUND(100.0 * SUM(is_npa) / COUNT(*), 2)   AS npa_rate_pct,
    ROUND(100.0 * SUM(is_delinquent) / COUNT(*), 2) AS delinquency_rate_pct,
    ROUND(AVG(collection_efficiency)*100, 2)   AS avg_collection_efficiency_pct
FROM loan_risk
GROUP BY cibil_band
ORDER BY cibil_band;


/* ============================================================
   Q6. EMPLOYMENT TYPE vs INCOME vs RISK
   ============================================================ */
SELECT
    employment_type,
    COUNT(*)                                   AS total_loans,
    ROUND(AVG(monthly_income),0)               AS avg_monthly_income,
    ROUND(AVG(loan_amount),0)                  AS avg_loan_amount,
    ROUND(AVG(loan_amount * 1.0 / monthly_income), 2) AS avg_loan_to_income_ratio,
    ROUND(100.0 * SUM(is_npa) / COUNT(*), 2)   AS npa_rate_pct,
    ROUND(100.0 * SUM(is_delinquent) / COUNT(*), 2) AS delinquency_rate_pct
FROM loan_risk
GROUP BY employment_type;


/* ============================================================
   Q7. DELINQUENCY DEEP-DIVE — late-payment behavior by vehicle type
   ============================================================ */
SELECT
    vehicle_type,
    SUM(installments_due)                                    AS installments_due,
    SUM(installments_late)                                   AS installments_late,
    ROUND(100.0 * SUM(installments_late) / SUM(installments_due), 2) AS pct_installments_late,
    ROUND(AVG(max_days_late), 1)                             AS avg_max_days_late
FROM loan_risk
GROUP BY vehicle_type
ORDER BY pct_installments_late DESC;


/* ============================================================
   Q8. STATE-WISE PORTFOLIO DISTRIBUTION (after cleaning duplicates)
   ============================================================ */
SELECT
    state,
    COUNT(*)                    AS total_loans,
    ROUND(SUM(loan_amount),0)   AS total_disbursed,
    ROUND(100.0*SUM(is_npa)/COUNT(*),2) AS npa_rate_pct,
    ROUND(100.0*SUM(is_delinquent)/COUNT(*),2) AS delinquency_rate_pct
FROM loan_risk
GROUP BY state
ORDER BY total_disbursed DESC;


/* ============================================================
   Q9. AGE-GROUP RISK PROFILE
   ============================================================ */
SELECT
    CASE
        WHEN age < 25 THEN '18-24'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
    END                                       AS age_group,
    COUNT(*)                                  AS total_loans,
    ROUND(100.0 * SUM(is_npa) / COUNT(*), 2)  AS npa_rate_pct,
    ROUND(100.0 * SUM(is_delinquent) / COUNT(*), 2) AS delinquency_rate_pct
FROM loan_risk
GROUP BY age_group
ORDER BY age_group;


/* ============================================================
   Q10. TOP 20 HIGHEST-RISK ACTIVE LOANS — worklist for collections team
   ============================================================ */
SELECT
    loan_id, customer_id, branch, vehicle_type, loan_amount,
    cibil_score, max_days_late, installments_unpaid,
    ROUND(collection_efficiency*100,1) AS collection_efficiency_pct
FROM loan_risk
WHERE is_npa = 1 OR is_delinquent = 1
ORDER BY max_days_late DESC, installments_unpaid DESC
LIMIT 20;


/* ============================================================
   Q11. MONTHLY COLLECTION EFFICIENCY TREND (EMI due vs EMI collected)
   ============================================================ */
SELECT
    strftime('%Y-%m', due_date)                        AS month,
    ROUND(SUM(emi_due),0)                              AS emi_due,
    ROUND(SUM(emi_paid),0)                             AS emi_collected,
    ROUND(100.0 * SUM(emi_paid) / SUM(emi_due), 2)     AS collection_efficiency_pct
FROM repayment_history
GROUP BY month
ORDER BY month;


/* ============================================================
   Q12. GENDER-WISE PORTFOLIO SNAPSHOT
   ============================================================ */
SELECT
    gender,
    COUNT(*)                                  AS total_loans,
    ROUND(AVG(loan_amount),0)                 AS avg_loan_amount,
    ROUND(100.0*SUM(is_npa)/COUNT(*),2)       AS npa_rate_pct,
    ROUND(100.0*SUM(is_delinquent)/COUNT(*),2) AS delinquency_rate_pct
FROM loan_risk
GROUP BY gender;

    




 