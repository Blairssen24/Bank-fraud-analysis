CREATE DATABASE Bank_Transactions_DB;

USE Bank_Transactions_DB;

SELECT * FROM bank_transactions;

--EXEC sp_help bank_transactions;

--SELECT COLUMN_NAME
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'bank_transactions';

--- 1. LONGITUTUDE AND LATITUDE
UPDATE bank_transactions
SET 
    Latitude = LTRIM(RTRIM(SUBSTRING(Geolocation_Latitude_Longitude, 1, CHARINDEX(',', Geolocation_Latitude_Longitude) - 1))),
    Longitude = LTRIM(RTRIM(SUBSTRING(Geolocation_Latitude_Longitude, CHARINDEX(',', Geolocation_Latitude_Longitude) + 1, LEN(Geolocation_Latitude_Longitude))));


-- Clean Latitude
UPDATE bank_transactions
SET Latitude = REPLACE(
                   REPLACE(
                       REPLACE(
                           REPLACE(Latitude, 'N', ''), 
                       'S', ''), 
                   '°', ''), 
               ' ', '');

-- Clean Longitude
UPDATE bank_transactions
SET Longitude = REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(Longitude, 'E', ''), 
                        'W', ''), 
                    '°', ''), 
                ' ', '');


ALTER TABLE bank_transactions
ALTER COLUMN Latitude FLOAT;

ALTER TABLE bank_transactions
ALTER COLUMN Longitude FLOAT;

-- 2. TIMESTAMP
ALTER TABLE bank_transactions
ADD TransactionDate DATE,
    TransactionTime TIME;

UPDATE bank_transactions
SET 
    TransactionDate = CAST([Timestamp] AS DATE),
    TransactionTime = CAST([Timestamp] AS TIME);

ALTER TABLE bank_transactions
ALTER COLUMN TransactionTime TIME(0);

-- 3. BANDWIDTH
ALTER TABLE bank_transactions
ADD Bandwidth_Group VARCHAR(20);

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bank_transactions';

UPDATE bank_transactions
SET Bandwidth_Group = CASE
    WHEN Slice_Bandwidth_Mbps >= 50 AND Slice_Bandwidth_Mbps < 100 THEN '50-100 Mbps'
    WHEN Slice_Bandwidth_Mbps >= 100 AND Slice_Bandwidth_Mbps < 150 THEN '100-150 Mbps'
    WHEN Slice_Bandwidth_Mbps >= 150 AND Slice_Bandwidth_Mbps <= 250 THEN '150-250 Mbps'
    ELSE 'Out of Range'
END;



-- 4. BANK TRANSACTION KPIs

-- Total Transactions
SELECT COUNT(DISTINCT Transaction_ID) AS Total_Transactions
FROM bank_transactions;

-- Total Transaction Amount
SELECT SUM([Transaction_Amount]) AS Total_Transaction_Amount
FROM bank_transactions;

-- By Transaction Status
SELECT [Transaction_Status], COUNT(*) AS Total
FROM bank_transactions
GROUP BY [Transaction_Status];

-- By Transaction Type
SELECT 
    Transaction_Type,
    COUNT(*) AS Total_Transactions,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions) AS DECIMAL(5,2)) AS Percent_of_Total
FROM bank_transactions
GROUP BY Transaction_Type
ORDER BY Total_Transactions DESC;

-- By Fraud Flag
SELECT 
    Fraud_Flag,
    COUNT(*) AS Total_Transactions,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions) AS DECIMAL(5,2)) AS Percent_of_Total
FROM bank_transactions
GROUP BY Fraud_Flag
ORDER BY Total_Transactions DESC;


-- By Device Used
SELECT [Device_Used], COUNT(*) AS Total
FROM bank_transactions
GROUP BY [Device_Used];

-- By Network Slice
SELECT [Network_Slice_ID], COUNT(*) AS Total
FROM bank_transactions
GROUP BY [Network_Slice_ID];

-- Daily Transactions Trend
SELECT TransactionDate, COUNT(*) AS Total_Transactions
FROM bank_transactions
GROUP BY TransactionDate
ORDER BY TransactionDate;

-- Hourly Transactions Trend
SELECT 
    DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, TransactionTime)/15)*15, 0) AS Time_Interval,
    COUNT(*) AS Total_Transactions
FROM bank_transactions
GROUP BY DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, TransactionTime)/15)*15, 0)
ORDER BY Time_Interval;

-- Trend by Region
SELECT Latitude, Longitude, COUNT(*) AS Transaction_Count
FROM bank_transactions
GROUP BY Latitude, Longitude;


-- 5. FRAUD DETECTION KPIs
-- Total Fraudulent Transactions
SELECT COUNT(*) AS Total_Fraud_Transactions
FROM bank_transactions
WHERE Fraud_Flag = 1;

-- Total Fraud Amount
SELECT SUM(Transaction_Amount) AS Total_Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1;

-- Fraud by Transaction Type
SELECT 
    Transaction_Type,
    COUNT(*) AS Fraud_Count,
    SUM(Transaction_Amount) AS Fraud_Amount,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions WHERE Fraud_Flag = 1) AS DECIMAL(5,2)) AS Fraud_Percent
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY Transaction_Type
ORDER BY Fraud_Count DESC;

-- Fraud by Network Slice
SELECT Network_Slice_ID, COUNT(*) AS Fraud_Count, SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY Network_Slice_ID
ORDER BY Fraud_Count DESC;

-- Fraud by Bandwidth Group
SELECT Bandwidth_Group, COUNT(*) AS Fraud_Count, SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY Bandwidth_Group
ORDER BY Fraud_Count DESC;

SELECT 
    Bandwidth_Group,
    COUNT(*) AS Fraud_Count,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions WHERE Fraud_Flag = 1) AS DECIMAL(5,2)) AS Fraud_Percent
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY Bandwidth_Group
ORDER BY Fraud_Count DESC;

-- Fraud by Device Used
SELECT Device_Used, COUNT(*) AS Fraud_Count, SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY Device_Used
ORDER BY Fraud_Count DESC;

-- Fraud Trend by Hour
SELECT DATEPART(HOUR, TransactionTime) AS HourOfDay,
       COUNT(*) AS Fraud_Count,
       SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY DATEPART(HOUR, TransactionTime)
ORDER BY HourOfDay;

-- Fraud Trend by 15-Minute Interval
SELECT DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, TransactionTime)/15)*15, 0) AS Time_Interval,
       COUNT(*) AS Fraud_Count,
       SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, TransactionTime)/15)*15, 0)
ORDER BY Time_Interval;

-- Fraud by Transaction Date
SELECT TransactionDate, COUNT(*) AS Fraud_Count, SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY TransactionDate
ORDER BY TransactionDate;

-- Fraud by Geolocation
SELECT Latitude, Longitude, COUNT(*) AS Fraud_Count, SUM(Transaction_Amount) AS Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
GROUP BY Latitude, Longitude;

-- Fraud Rate (%)
SELECT 
    CAST(SUM(CASE WHEN Fraud_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Fraud_Rate_Percent
FROM bank_transactions;

-- Average Fraud Amount
SELECT AVG(Transaction_Amount) AS Avg_Fraud_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1;

-- Largest Fraud Transaction
SELECT TOP 1 Transaction_ID, Transaction_Amount
FROM bank_transactions
WHERE Fraud_Flag = 1
ORDER BY Transaction_Amount DESC;

-- 6. DETAILS
SELECT
    Transaction_ID,
    Sender_Account_ID,
    Receiver_Account_ID,
    Transaction_Amount,
    Transaction_Type,
    Transaction_Status,
    Fraud_Flag,
    Network_Slice_ID,
    Bandwidth_Group
FROM bank_transactions;
