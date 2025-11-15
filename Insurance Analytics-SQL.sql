-- ========================================

CREATE DATABASE insurance_analytics_sql;
USE insurance_analytics_sql;

-- ========================================
-- Q1:

SELECT
    `Account Executive`,
    income_class,
    COUNT(invoice_number) AS count_of_invoice_number
FROM
    invoice
GROUP BY 1, 2
ORDER BY count_of_invoice_number DESC;

-- ========================================
-- Q2:

DESCRIBE meetings;
SELECT meeting_date, Account_Exe_ID, Account_Executive
FROM meetings
LIMIT 20;
SELECT YEAR(meeting_date) AS year,
       COUNT(*) AS meeting_count
FROM meetings
GROUP BY YEAR(meeting_date)
ORDER BY year;
SELECT YEAR(meeting_date) AS year,
       COUNT(DISTINCT meeting_date) AS unique_meetings
FROM meetings
GROUP BY YEAR(meeting_date)
ORDER BY year;
SELECT meeting_date,
       STR_TO_DATE(meeting_date, '%d-%m-%Y') AS parsed_date
FROM meetings
LIMIT 20;
SELECT YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS year,
       COUNT(*) AS meeting_count
FROM meetings
WHERE meeting_date IS NOT NULL AND TRIM(meeting_date) <> ''
GROUP BY YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y'))
ORDER BY year;
SELECT YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS year,
       COUNT(DISTINCT STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS unique_meetings
FROM meetings
WHERE meeting_date IS NOT NULL AND TRIM(meeting_date) <> ''
GROUP BY YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y'))
ORDER BY year;
SELECT Account_Executive,
       YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS year,
       COUNT(DISTINCT STR_TO_DATE(meeting_date, '%d-%m-%Y')) AS meetings_for_exec
FROM meetings
WHERE meeting_date IS NOT NULL AND TRIM(meeting_date) <> ''
GROUP BY Account_Executive, YEAR(STR_TO_DATE(meeting_date, '%d-%m-%Y'))
ORDER BY Account_Executive, year;
ALTER TABLE meetings
ADD COLUMN meeting_date_dt DATE;
UPDATE meetings
SET meeting_date_dt = STR_TO_DATE(meeting_date, '%d-%m-%Y')
WHERE meeting_date IS NOT NULL AND TRIM(meeting_date) <> '';
SELECT meeting_date, meeting_date_dt
FROM meetings
WHERE meeting_date_dt IS NULL AND (meeting_date IS NOT NULL AND TRIM(meeting_date) <> '')
LIMIT 20;
SELECT YEAR(meeting_date_dt) AS year, COUNT(*) AS meeting_count
FROM meetings
WHERE meeting_date_dt IS NOT NULL
GROUP BY YEAR(meeting_date_dt)
ORDER BY year;
SELECT year, COUNT(*) FROM meetings GROUP BY year ORDER BY year;

-- ========================================
-- Q3:

select
    t.income_class as category,
    t.target,
    
    -- achvmnt amt rounded 2 dec
    round(ifnull(a.achieved, 0), 2) as achieved,
    
    -- invc amt rounded 2 dec
    round(ifnull(i.invoice, 0), 2) as invoice,

    -- % of target achvd (placed %)
    concat(
        round(ifnull(a.achieved, 0) / nullif(t.target, 0) * 100, 2),
        '%'
    ) as placed_percentage,

    -- % of target invoiced (invcs %)
    concat(
        round(ifnull(i.invoice, 0) / nullif(t.target, 0) * 100, 2),
        '%'
    ) as invoice_percentage

from
    -- 🎯 tgt tbl: total budgets by incm cls
    (
        select 'cross sell' as income_class, sum(`cross sell bugdet`) as target
        from budgets
        union all
        select 'new' as income_class, sum(`new budget`) as target
        from budgets
        union all
        select 'renewal' as income_class, sum(`renewal budget`) as target
        from budgets
    ) as t

    -- 💰 achvmnts: sum of brokerage + fees by cls
    left join (
        select
            income_class,
            sum(amount) as achieved
        from (
            select income_class, amount from brokerage
            union all
            select income_class, amount from fees
        ) as combined
        group by income_class
    ) as a
    on a.income_class = t.income_class

    -- 🧾 invcs: total invcs by cls
    left join (
        select
            income_class,
            sum(amount) as invoice
        from invoice
        group by income_class
    ) as i
    on i.income_class = t.income_class

order by field(t.income_class, 'cross sell', 'new', 'renewal');

-- ========================================
-- Q4:

SELECT 
    stage,
    SUM(revenue_amount) AS total_revenue,
    COUNT(*) AS total_opportunities
FROM 
    opportunity
GROUP BY 
    stage
ORDER BY
    total_revenue DESC

-- ========================================
-- Q5:

SELECT 
    *
FROM
    meeting;
SELECT 
    `Account Executive`, COUNT(`Account Exe ID`) AS count_acct_exec_id
FROM
    meeting
GROUP BY 1
ORDER BY count_acct_exec_id DESC;

-- ========================================
-- Q6:

SELECT 
    *
FROM
    opportunity;
SELECT 
    `opportunity_name`, SUM(revenue_amount) AS count_of_opportunity_name
FROM
    opportunity
GROUP BY 1
ORDER BY count_of_opportunity_name DESC
LIMIT 4;
#-------------Opportunity By Product Distribution-----------------------#
SELECT 
    product_group, COUNT(opportunity_name) AS count_of_opportunity_name
FROM
    opportunity
GROUP BY 1
ORDER BY count_of_opportunity_name DESC;
#-------------------Open Oppty Top-4--------------------------------#
SELECT 
    `opportunity_name`, SUM(revenue_amount) AS count_of_opportunity_name
FROM
    opportunity
GROUP BY 1
ORDER BY count_of_opportunity_name DESC
LIMIT 4;
#--------------Total opportunities--------------#
SELECT 
    SUM(Total_count) AS Total_Opportunities
FROM
    (SELECT 
        stage, COUNT(opportunity_name) AS Total_count
    FROM
        opportunity
    GROUP BY 1)abc;
    #-----------------Total Open Opportunities------------------#
   select * from opportunity; 
 SELECT 
    SUM(Total_count) AS Total_Open_Opportunities
FROM
    (SELECT 
        stage, COUNT(opportunity_name) AS Total_count
    FROM
        opportunity
        where stage in('Qualify Opportunity','Propose Solution' )
    GROUP BY 1)abc;  

-- ========================================