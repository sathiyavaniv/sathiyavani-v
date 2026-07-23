CREATE DATABASE churn_db;
SHOW DATABASES;
USE churn_db;
SELECT * FROM customer_churn_data;
-- Check if data loaded correctly (should show 7043)
SELECT COUNT(*) AS total_rows FROM customer_churn_data;
-- QUERY 1 : OVERALL CHURN SUMMARY
--           How many customers left and how much money was lost?
SELECT
    COUNT(*) AS total_customers,
    SUM(Churn = '1') AS customers_who_left,
    SUM(Churn = '0') AS customers_who_stayed,
    ROUND(SUM(Churn = '1') * 100.0 / COUNT(*), 2) AS churn_rate_percent,
    ROUND(SUM(CASE WHEN Churn = '1' THEN MonthlyCharges ELSE 0 END), 2) AS monthly_revenue_lost,
    ROUND(SUM(CASE WHEN Churn = '1' THEN MonthlyCharges ELSE 0 END) * 12, 2) AS yearly_revenue_lost
FROM customer_churn_data;
#QUERY 2 : AVERAGE TENURE — WHO STAYED LONGER?
--           Churned customers leave much earlier than loyal ones
select  
        churn,
        count(*) as customers,
        Round(avg(tenure),2) as avg_month_stayed,
        Round(avg(Monthlycharges),2) as avg_monthly_charges
FROM customer_churn_data 
GROUP  by churn;
-- QUERY 3 : CHURN BY CONTRACT TYPE
--           Month-to-month customers churn the most
SELECT
    Contract  AS contract_type,
    COUNT(*)  AS total_customers,
    SUM(Churn = '1') AS churned,
    ROUND(SUM(Churn = '1') * 100.0 / COUNT(*), 2) AS churn_rate_percent
FROM customer_churn_data
group by Contract
order by churn_rate_percent desc;
-- QUERY 4 : CHURN BY PAYMENT METHOD
--           Electronic check users churn the most
select 
      paymentMethod as payment_method,
      count(*) as total_customers,
      sum(churn="1") as churned,
      round(sum(churn="1")* 100.0 / count(*),2) as churn_rate_percent
from customer_churn_data
group by PaymentMethod
order by churn_rate_percent desc;
-- QUERY 6 : CHURN BY ONLINE SECURITY ADD-ON
--           Customers without Online Security leave more
SELECT
    OnlineSecurity                                        AS online_security,
    COUNT(*)                                              AS total_customers,
    SUM(Churn = '1')                                    AS churned,
    ROUND(SUM(Churn = '1') * 100.0 / COUNT(*), 2)      AS churn_rate_percent
FROM customer_churn_data
WHERE InternetService != '0'    -- only for internet users
GROUP BY OnlineSecurity
ORDER BY churn_rate_percent DESC;
-- QUERY 7 : CHURN BY TECH SUPPORT ADD-ON
--           Same pattern — no support = higher churn
select  
      Techsupport as Techsupport,
      count(*) as total_customers,
      sum(churn = '1') as churned,
      round(sum(churn = '1') * 100.0 / count(*),2) as churn_rate_percent
from customer_churn_data
where  Internetservice !='0'
group by Techsupport
order by churn_rate_percent Desc;
-- QUERY 8 : CHURN BY SENIOR CITIZEN STATUS
--           Senior citizens churn significantly more
select 
      case seniorcitizen
          when 1 then 'senior citizen'
          when 0 then 'not senior'
	  End     as customer_type,
      count(*) as total_customers,
      sum(churn='1') as customer_churned,
      round(sum(churn='1') * 100.0 / count(*),2) as churn_rate_percent,
      round(avg(monthlyCharges),2) as avg_monthly_bill
from customer_churn_data
group by seniorcitizen;
-- QUERY 9 : CHURN BY GENDER
--           Is there a gender difference
select
      gender,
      count(*) as total_customers,
      sum(churn = '1') as churned_customers,
      round(sum(churn = '1') *100.0 / count(*),2) as churn_rate_percent
from customer_churn_data
group by gender;
-- QUERY 10 : CHURN BY PARTNER AND DEPENDENTS
--            Customers with no family ties churn more
select 
      partner,dependents,
      count(*) as total_customer,
      sum(churn = '1') as churned_customers,
      round(sum(churn = '1')*100.0 / count(*),2) as churn_rate_percent
from customer_churn_data
group by partner,dependents
order by churn_rate_percent Desc;
-- QUERY 11 : CHURN BY TENURE GROUP
--            New customers are the most at risk
SELECT
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN '0-12 months  (New)'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months (Growing)'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months (Mature)'
        ELSE                               '49+ months   (Loyal)'
    END                                                   AS customer_stage,
    COUNT(*)                                              AS total_customers,
    SUM(Churn = '1')                                    AS churned,
    ROUND(SUM(Churn = '1') * 100.0 / COUNT(*), 2)      AS churn_rate_percent
FROM customer_churn_data
GROUP BY customer_stage
ORDER BY MIN(tenure);
-- QUERY 11 : CHURN BY TENURE GROUP
--            New customers are the most at risk
SELECT
    Contract,
    InternetService,
    COUNT(*)                                              AS total_customers,
    SUM(Churn = '1')                                    AS churned,
    ROUND(SUM(Churn = '1') * 100.0 / COUNT(*), 2)      AS churn_rate_percent,
    ROUND(SUM(CASE WHEN Churn='1' THEN MonthlyCharges ELSE 0 END), 2)
                                                          AS monthly_revenue_lost
FROM customer_churn_data
WHERE Contract = 'Month-to-month'
  AND InternetService = 'Fiber optic'
GROUP BY Contract, InternetService;
 -- QUERY 14 : REVENUE AT RISK BY SEGMENT
--            Where is the company losing the most money?
SELECT
    Contract,
    InternetService,
    ROUND(SUM(CASE WHEN Churn='1' THEN MonthlyCharges ELSE 0 END), 2)
                                                          AS monthly_rev_lost,
    ROUND(SUM(CASE WHEN Churn='1' THEN MonthlyCharges ELSE 0 END) * 12, 2)
                                                          AS yearly_rev_lost
FROM customer_churn_data
GROUP BY Contract, InternetService
ORDER BY yearly_rev_lost DESC;
-- QUERY 15 : RETENTION STRATEGY SAVINGS ESTIMATE
--            How much can we save with each action?
-- STRATEGY 1: Move e-check users to auto-pay
SELECT
    'Switch E-Check to Auto-Pay'            AS strategy,
    COUNT(*)                                AS customers_targeted,
    ROUND(SUM(MonthlyCharges), 2)           AS their_total_monthly_bill,
    ROUND(SUM(MonthlyCharges) * (0.453 - 0.5124), 2)   AS monthly_saving,
    ROUND(SUM(MonthlyCharges) * (0.453 - 0.5124) * 12, 2) AS yearly_saving
FROM customer_churn_data
WHERE PaymentMethod = 'Electronic check'
  AND Churn = '0'

UNION ALL
-- STRATEGY 2: Add Online Security + Tech Support to Fiber customers
-- (churn rate drops from 41.9% to ~25%)
SELECT
    'Bundle Security+Support for Fiber'     AS strategy,
    COUNT(*)                                AS customers_targeted,
    ROUND(SUM(MonthlyCharges), 2)           AS their_total_monthly_bill,
    ROUND(SUM(MonthlyCharges) * (0.4177 - 0.1461), 2)   AS monthly_saving,
    ROUND(SUM(MonthlyCharges) * (0.4177 - 0.1461) * 12, 2) AS yearly_saving
FROM customer_churn_data
WHERE InternetService = 'Fiber optic'
  AND OnlineSecurity  = '0'
  AND TechSupport     = '0'
  AND Churn = '0'

UNION ALL

-- STRATEGY 3: Offer annual contract deals to month-to-month customers
-- (churn rate drops from 42.7% to ~11%)
SELECT
    'Convert Month-to-Month to Annual'      AS strategy,
    COUNT(*)                                AS customers_targeted,
    ROUND(SUM(MonthlyCharges), 2)           AS their_total_monthly_bill,
    ROUND(SUM(MonthlyCharges) * (0.4271 - 0.1127), 2)   AS monthly_saving,
    ROUND(SUM(MonthlyCharges) * (0.4271 - 0.1127) * 12, 2) AS yearly_saving
FROM customer_churn_data
WHERE Contract = 'Month-to-month'
  AND Churn = '0'

UNION ALL

-- STRATEGY 4: Special retention plan for senior citizens
-- (churn rate drops from 41.7% to ~28%)
SELECT
    'Senior Citizen Retention Program'      AS strategy,
    COUNT(*)                                AS customers_targeted,
    ROUND(SUM(MonthlyCharges), 2)           AS their_total_monthly_bill,
    ROUND(SUM(MonthlyCharges) * (0.4168 - 0.2361), 2)   AS monthly_saving,
    ROUND(SUM(MonthlyCharges) * (0.4168 - 0.2361) * 12, 2) AS yearly_saving
FROM customer_churn_data
WHERE SeniorCitizen = 1
  AND Churn = '0';


-- END 


