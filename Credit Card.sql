SELECT *
FROM credit_card

SELECT *
FROM cc_customer

USE [Credit Card]

--Total Revenue
SELECT Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue
FROM credit_card

--Avg Total Transaction Amount
SELECT CAST(CAST(SUM(Total_trans_amt) AS DECIMAL(10,2)) / CAST(COUNT(Total_trans_amt)
AS DECIMAL(10,2)) AS DECIMAL(10,2))  Avg_Trans_Amt
FROM credit_card

-- Customers with more than Average Transaction Amount
WITH AVGTRANSAMT AS
( SELECT AVG(Total_trans_amt) Avg_Trans_Amt
FROM credit_card
)
SELECT cc.Client_Num, cc.Total_Trans_Amt
FROM credit_card cc, AVGTRANSAMT av
WHERE Total_trans_amt > Avg_Trans_Amt
ORDER BY Total_Trans_Amt

-- Customers with more than Average Income
WITH AVGINCOME AS
( SELECT AVG(income) Avg_income
FROM cc_customer
)
SELECT c.Client_Num, c.income
FROM cc_customer c, AVGINCOME av
WHERE income > Avg_income
ORDER BY income


--Quaterly Revenue Trend in percent and Total Revenue
SELECT Qtr, Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue,
CAST(CAST(SUM(Annual_fees + total_trans_Amt + Interest_earned) AS DECIMAL(10,2)) * 100/
(SELECT CAST(SUM(Annual_fees + total_trans_Amt + Interest_earned)  AS DECIMAL(10,2))  FROM credit_card) AS DECIMAL(10,2)) PCT
FROM credit_card
GROUP BY Qtr
ORDER BY Total_Revenue DESC


--Monthly Revenue Trend
SELECT MONTH(Week_Start_Date) Month_Num,
DATENAME(MONTH, Week_Start_Date) Monthly_Revenue, SUM(Total_Trans_Vol) Total_Trans,
Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue
FROM credit_card
GROUP BY DATENAME(MONTH, Week_Start_Date), MONTH(Week_Start_Date)
ORDER BY MONTH(Week_Start_Date)

--Revenue by Expenses Type 
SELECT Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue,
Exp_Type
FROM credit_card
GROUP BY Exp_Type
ORDER BY Total_Revenue DESC

--Revenue by Gender
SELECT Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue, CU.Gender
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY CU.Gender
ORDER BY Total_Revenue DESC

--Revenue by Marital Status in percent
SELECT  CU.Marital_Status,
CAST(CAST(SUM(Annual_fees + total_trans_Amt + Interest_earned) AS DECIMAL(10,2)) * 100/
(SELECT CAST(SUM(Annual_fees + total_trans_Amt + Interest_earned)  AS DECIMAL(10,2))  FROM credit_card) AS DECIMAL(10,2)) PCT
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY CU.Marital_Status
ORDER BY PCT DESC

--Revenue by Education Level in percent
SELECT  CU.Education_Level, COUNT(Education_Level) Total_Level_of_Edu,
CAST(CAST(SUM(Annual_fees + total_trans_Amt + Interest_earned) AS DECIMAL(10,2)) * 100/
(SELECT CAST(SUM(Annual_fees + total_trans_Amt + Interest_earned)  AS DECIMAL(10,2))  FROM credit_card) AS DECIMAL(10,2)) PCT
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY CU.Education_Level
ORDER BY PCT DESC

--Customer Satisfaction by No of Customers, Avg Credit limit & Total Credit limit
SELECT
	CASE 
WHEN Cust_Satisfaction_Score = 1 THEN 'Very Dissatisfied'
WHEN Cust_Satisfaction_Score = 2 THEN 'Dissatisfied'
WHEN Cust_Satisfaction_Score = 3 THEN 'Neutral'
WHEN Cust_Satisfaction_Score = 4 THEN 'Satisfied'
ELSE 'Very Satisfied'
END AS Cust_Satisfaction,
ROUND(SUM(Credit_limit),2) Credit_Limit,
ROUND(AVG(Credit_limit),2) Avg_Credit_Limit,
COUNT(CR.Client_Num) No_of_Cust
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY 
CASE 
WHEN Cust_Satisfaction_Score = 1 THEN 'Very Dissatisfied'
WHEN Cust_Satisfaction_Score = 2 THEN 'Dissatisfied'
WHEN Cust_Satisfaction_Score = 3 THEN 'Neutral'
WHEN Cust_Satisfaction_Score = 4 THEN 'Satisfied'
ELSE 'Very Satisfied'
END
ORDER BY Credit_Limit DESC

--Avg Transaction Amt & Vol Per Day
SELECT DAY(Week_Start_Date) Daily,
AVG(Total_Trans_Amt) Avg_Trans_Amt,
AVG(Total_Trans_Vol) Avg_Trans_Vol
FROM credit_card
GROUP BY DAY(Week_Start_Date)
ORDER BY Daily

--Revnue and Income by Age category
SELECT
	CASE 
WHEN Customer_Age BETWEEN 0 AND 30 THEN 'Youth'
WHEN Customer_Age BETWEEN 31 AND 40 THEN 'Young-Youth'
WHEN Customer_Age BETWEEN 41 AND 60 THEN 'Adult'
WHEN Customer_Age BETWEEN 61 AND 70 THEN 'Elder'
ELSE 'Old'
END AS Age_Category,
Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue,
Round(SUM(Income),2) Cust_Income
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY 
	CASE 
WHEN Customer_Age BETWEEN 0 AND 30 THEN 'Youth'
WHEN Customer_Age BETWEEN 31 AND 40 THEN 'Young-Youth'
WHEN Customer_Age BETWEEN 41 AND 60 THEN 'Adult'
WHEN Customer_Age BETWEEN 61 AND 70 THEN 'Elder'
ELSE 'Old'
END
ORDER BY Total_Revenue DESC

--Top 5 states by Revenue 
SELECT TOP 5 CU.state_cd, Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY CU.state_cd
ORDER BY Total_Revenue DESC

--Bottom 5 states by Revenue 
SELECT TOP 5 CU.state_cd, Round(SUM(Annual_fees + total_trans_Amt + Interest_earned),2) Total_Revenue
FROM credit_card CR
JOIN cc_customer CU
ON CR.Client_Num = CU.Client_Num
GROUP BY CU.state_cd
ORDER BY Total_Revenue ASC 

--Correlation Coefficient Between Income and Revenue
WITH CorrelationData AS (
    SELECT
        CAST(COUNT(*) AS BIGINT) AS N,
        CAST(SUM(CAST(Income AS DECIMAL(38,10))) AS DECIMAL(38,10)) AS Total_Income,
        CAST(SUM(CAST(Annual_fees AS DECIMAL(38,10)) + CAST(total_trans_Amt AS DECIMAL(38,10)) +
		CAST(Interest_earned AS DECIMAL(38,10))) AS DECIMAL(38,10)) AS Total_Revenue,
        CAST(SUM(CAST(Income AS DECIMAL(38,10)) * (CAST(Annual_fees AS DECIMAL(38,10)) + 
		CAST(total_trans_Amt AS DECIMAL(38,10)) + CAST(Interest_earned AS DECIMAL(38,10)))) AS DECIMAL(38,10)) AS Total_Income_and_Revenue,
        CAST(SUM(CAST(Income AS DECIMAL(38,10)) * CAST(Income AS DECIMAL(38,10))) AS DECIMAL(38,10)) AS Sum_Income_Square,
        CAST(SUM((CAST(Annual_fees AS DECIMAL(38,10)) + CAST(total_trans_Amt AS DECIMAL(38,10)) + CAST(Interest_earned AS DECIMAL(38,10))) * 
                  (CAST(Annual_fees AS DECIMAL(38,10)) + CAST(total_trans_Amt AS DECIMAL(38,10)) + CAST(Interest_earned AS DECIMAL(38,10)))) AS DECIMAL(38,10)) AS Sum_Revenue_Square
    FROM credit_card CR
    JOIN cc_customer CU
    ON CR.Client_Num = CU.Client_Num
),
IntermediateValues AS (
    SELECT
        N,
        Total_Income,
        Total_Revenue,
        Total_Income_and_Revenue,
        Sum_Income_Square,
        Sum_Revenue_Square,
        CAST(CAST(N AS DECIMAL(38,10)) * Total_Income_and_Revenue - Total_Income * Total_Revenue AS DECIMAL(38,10)) AS Numerator,
        CAST(SQRT(CAST(CAST(N AS DECIMAL(38,10)) * Sum_Income_Square - Total_Income * Total_Income AS DECIMAL(38,10))) AS DECIMAL(38,10)) AS Denominator_Income,
        CAST(SQRT(CAST(CAST(N AS DECIMAL(38,10)) * Sum_Revenue_Square - Total_Revenue * Total_Revenue AS DECIMAL(38,10))) AS DECIMAL(38,10)) AS Denominator_Revenue
    FROM CorrelationData
)
SELECT 
    Numerator / (Denominator_Income * Denominator_Revenue) AS Correlation_Coefficient
FROM IntermediateValues;


SELECT Client_Num, Total_Trans_Vol
FROM credit_card
WHERE Total_Trans_Vol > (SELECT AVG(Total_Trans_Vol)
FROM credit_card)

SELECT Client_Num, AVG(Total_Trans_Vol)
FROM credit_card
GROUP BY Client_Num
HAVING > AVG(Total_Trans_Vol)

With Customername(state_cd, Exp_type, income)
as
(SELECT Exp_type
From credit_card
)
SELECT state_cd, Exp_type, income
FROM credit_card CR
JOIN Customername cc
ON cr.Client_Num = cc.Client_Num

WITH Customername AS 
(
    SELECT state_cd, Exp_type, income
    FROM credit_card
)
SELECT CR.state_cd, CR.Exp_type, CR.income
FROM credit_card CR
JOIN Customername cc
ON CR.Client_Num = cc.Client_Num;



