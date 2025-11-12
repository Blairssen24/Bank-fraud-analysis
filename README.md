# 💳 Bank Transactions & Fraud Detection Analysis
**Data Storytelling | SQL + Power BI | Financial Risk & Performance Insights**

A comprehensive analysis of digital banking transactions to monitor financial activity, detect fraudulent behavior, and assess network performance factors such as bandwidth and latency that influence transaction reliability.

---

## 📘 Table of Contents

1. [Project Overview](#1-project-overview)  
2. [Business Problem Statement](#2-business-problem-statement)  
3. [Analytical Objectives](#3-analytical-objectives)  
4. [Tools & Technologies](#4-tools--technologies)  
5. [Dataset Overview](#5-dataset-overview)  
6. [Data Preparation & Cleaning (SQL)](#6-data-preparation--cleaning-sql)  
7. [KPIs & SQL Queries](#7-kpis--sql-queries)
   - [Bank Transaction KPIs](#bank-transaction-kpis)
   - [Fraud Detection KPIs](#fraud-detection-kpis) 
8. [ Key Insights & Observations](#8-key-insights--observations)  
9. [Recommendations & Actionable Steps](#9-recommendations--actionable-steps)
10. [Power BI Dashboard Preview](#10-power-bi-dashboard-preview)   
11. [Conclusion](#11-conclusion)  
12. [Appendix — SQL Scripts](#12-appendix--sql-scripts)

---

## 1. Project Overview

This project analyzes digital banking transactions to uncover insights into operational performance, network behavior, and fraudulent activity. 

The analysis combines **SQL** for data cleaning, transformation, and KPI calculation with **Power BI** for interactive dashboards and storytelling.  

Key goals include:

- Measuring transaction performance across devices, time, and network slices.
- Detecting and quantifying fraudulent transactions and patterns.
- Evaluating network factors such as **Bandwidth** and **Latency** on transaction reliability.
- Providing actionable insights to improve fraud detection, operational efficiency, and customer trust.

By combining data engineering, analytical modeling, and visualization, this project enables the bank to proactively monitor financial activity, strengthen fraud defenses, and optimize digital transaction infrastructure.

---

## 2. Business Problem Statement

Financial institutions increasingly face challenges associated with:

- Unauthorized transactions
- Suspicious geolocation patterns
- Network slices with high latency and unstable bandwidth
- Abnormal spending/trading frequency from the same device or region

Such activities weaken customer trust, expose the bank to regulatory penalties, and lead to financial loss.

This analysis focuses on:

- Detecting fraudulent transactions using behavioral, network, and contextual patterns.
- Monitoring network performance (Bandwidth, Latency) to prevent degraded service quality.
- Understanding customer transaction trends to enable proactive fraud defense.

---

## 3. Analytical Objectives

The main aim of this analysis is to transform raw bank transaction data into **actionable insights** that guide operational, security, and strategic decisions.

Specifically, the objectives are to:

- Measure **transaction performance** across devices, timestamps, and network slices.
- Identify and quantify **fraudulent transactions**, including total counts, monetary impact, and distribution by transaction type, device, location, and bandwidth group.
- Detect **behavioral and temporal fraud trends**, such as peak fraud hours and unusual geolocation patterns.
- Evaluate **network performance factors** (Bandwidth, Latency) and their impact on successful and fraudulent transactions.
- Provide **drill-down transaction visibility** for fraud investigation and business decision-making.
- Support **data-driven decision making** to enhance security, optimize network resources, and improve customer trust.

---

## 4. Tools & Technologies

| Tool / Technology | Purpose in the Project |
|------------------|------------------------|
| **SQL Server** | Used for data cleaning, transformation, KPI calculations, and analytical querying. |
| **Power BI** | Used to create interactive dashboards, visualizations, and data storytelling insights. |
| **Excel** | Used for preliminary dataset review, validation, and cross-checking. |
| **GitHub** | Used for version control, README documentation, and project showcase. |

> SQL forms the analytical foundation while Power BI transforms insights into interactive visualizations for decision-making.

---

## 5. Dataset Overview

The dataset contains **digital bank transaction records** across multiple accounts, devices, and network slices. Each row represents a unique transaction.

| Column Name | Description |
|------------|-------------|
| **Transaction_ID** | Unique identifier for each transaction |
| **Sender_Account_ID** | Account initiating the transaction |
| **Receiver_Account_ID** | Account receiving the transaction |
| **Transaction_Amount** | Monetary value of the transaction |
| **Transaction_Type** | Type of transaction (e.g., Deposit, Withdrawal) |
| **Timestamp** | Date and time of the transaction |
| **Transaction_Status** | Status of the transaction (Success/Failed) |
| **Fraud_Flag** | Indicates whether the transaction is fraudulent (TRUE/FALSE) |
| **Geolocation_Latitude_Longitude** | Latitude and longitude of transaction origin |
| **Device_Used** | Device used to perform the transaction (Desktop, Mobile) |
| **Network_Slice_ID** | Network slice through which the transaction occurred |
| **Latency_ms** | Time taken for network response in milliseconds |
| **Slice_Bandwidth_Mbps** | Network slice bandwidth during the transaction |
| **PIN_Code** | Masked identifier for the user |
| **Latitude** | Cleaned latitude coordinate (FLOAT) |
| **Longitude** | Cleaned longitude coordinate (FLOAT) |
| **TransactionDate** | Date portion of the timestamp |
| **TransactionTime** | Time portion of the timestamp |
| **Bandwidth_Group** | Categorized bandwidth group (50-100 Mbps, etc.) |

> These columns form the foundation for KPI calculations, fraud detection analysis, and network performance evaluation.

---

## 6. Data Preparation & Cleaning (SQL)

Before analysis, the dataset was cleaned and transformed in **SQL** to ensure accuracy, consistency, and readiness for KPI calculation and visualization.

### ✅ Key Cleaning Steps
- **Split Geolocation**: Latitude and Longitude extracted from the combined column and cleaned (removing N, S, E, W, spaces, and symbols). Converted to `FLOAT`.  
- **Split Timestamp**: Timestamp separated into `TransactionDate` (DATE) and `TransactionTime` (TIME).  
- **Categorize Bandwidth**: Created `Bandwidth_Group` based on `Slice_Bandwidth_Mbps`.  
- **Trim Text Columns**: Removed extra spaces from string columns for consistency.  
- **Correct Data Types**: Ensured numeric, date, and float types are correctly set for calculation and aggregation.

### 🧹 Sample SQL Cleaning & Feature Engineering

```sql
-- Split Latitude and Longitude
UPDATE bank_transactions
SET 
    Latitude = LTRIM(RTRIM(SUBSTRING(Geolocation_Latitude_Longitude, 1, CHARINDEX(',', Geolocation_Latitude_Longitude) - 1))),
    Longitude = LTRIM(RTRIM(SUBSTRING(Geolocation_Latitude_Longitude, CHARINDEX(',', Geolocation_Latitude_Longitude) + 1, LEN(Geolocation_Latitude_Longitude))));

-- Clean Latitude and Longitude
UPDATE bank_transactions
SET Latitude = REPLACE(REPLACE(REPLACE(REPLACE(Latitude,'N',''),'S',''),'°',''),' ',''),
    Longitude = REPLACE(REPLACE(REPLACE(REPLACE(Longitude,'E',''),'W',''),'°',''),' ','');

ALTER TABLE bank_transactions
ALTER COLUMN Latitude FLOAT;
ALTER TABLE bank_transactions
ALTER COLUMN Longitude FLOAT;

-- Split Timestamp
ALTER TABLE bank_transactions
ADD TransactionDate DATE, TransactionTime TIME;

UPDATE bank_transactions
SET 
    TransactionDate = CAST(Timestamp AS DATE),
    TransactionTime = CAST(Timestamp AS TIME);

-- Create Bandwidth Group
ALTER TABLE bank_transactions
ADD Bandwidth_Group VARCHAR(20);

UPDATE bank_transactions
SET Bandwidth_Group = CASE
    WHEN Slice_Bandwidth_Mbps >= 50 AND Slice_Bandwidth_Mbps < 100 THEN '50-100 Mbps'
    WHEN Slice_Bandwidth_Mbps >= 100 AND Slice_Bandwidth_Mbps < 150 THEN '100-150 Mbps'
    WHEN Slice_Bandwidth_Mbps >= 150 AND Slice_Bandwidth_Mbps <= 250 THEN '150-250 Mbps'
    ELSE 'Out of Range'
END;
```
---

## 7. KPIs & SQL Queries

### 📌 Bank Transaction KPIs

These KPIs focus on understanding **transaction volume, performance, and trends** across time, devices, and network slices.

---

#### 1. Total Transactions
```sql
SELECT COUNT(*) AS Total_Transactions
FROM bank_transactions;
```

---

## 8. Key Insights & Observations

Based on the analysis of bank transaction data, several important insights emerge:

### 📌 Transaction Patterns
- **Peak Transaction Hours:** The dataset shows most transactions occur around late morning (e.g., 10 AM), indicating high activity periods for the bank’s systems.
- **Transaction Types:** Deposits and withdrawals dominate the volume, but analyzing percentages highlights which types contribute most to total transaction value.
- **Device Usage:** Desktop and mobile devices show distinct usage patterns, which could influence security and fraud detection strategies.

### 📌 Fraud Insights
- **Fraud Occurrence:** A small but significant proportion of transactions are flagged as fraudulent, requiring targeted monitoring.
- **Fraud by Device & Network:** Some devices or network slices may experience higher fraud rates, pointing to potential vulnerabilities.
- **Temporal Fraud Trends:** Fraudulent transactions are not evenly distributed across the day, with spikes during high-transaction periods.

### 📌 Network Performance
- **Bandwidth Impact:** Transactions are influenced by network slice bandwidth; low-bandwidth slices may affect transaction success.
- **Latency Consideration:** While not yet fully analyzed, latency (ms) could affect transaction processing and user experience.

### 📌 Geolocation Patterns
- **Transaction Origin:** Latitude and longitude analysis shows the geographic spread of transactions.
- **High-Risk Regions:** Clustering of transactions from unusual or distant locations may indicate fraudulent behavior.

> These insights set the stage for **targeted fraud detection, network optimization, and proactive risk mitigation** in digital banking operations.

---

## 9. Recommendations & Actionable Steps

Based on the analysis of transaction, fraud, and network performance data, the following recommendations are proposed to enhance banking operations and reduce financial risk:

### 📌 Fraud Prevention
- **Strengthen Authentication Controls:** Enforce multi-factor authentication, especially for high-risk devices and unusual geolocations.
- **Monitor Fraud Patterns:** Use automated alerts for transactions that match suspicious patterns in frequency, amount, or origin.
- **Focus on High-Risk Network Slices:** Prioritize monitoring for network slices and bandwidth groups that exhibit higher fraud rates.

### 📌 Network Optimization
- **Bandwidth Allocation:** Ensure sufficient bandwidth for high-transaction periods to reduce failed or delayed transactions.
- **Latency Monitoring:** Implement performance tracking for low-latency requirements, particularly during peak hours.
- **Device Performance Analysis:** Identify devices or platforms prone to transaction failures and optimize accordingly.

### 📌 Transaction Monitoring
- **Temporal Trend Analysis:** Continuously monitor hourly transaction volumes to anticipate and prevent peak-time bottlenecks.
- **Geolocation Validation:** Flag unusual transaction locations or clustering for review.
- **Daily Reporting:** Provide dashboards highlighting total transactions, fraud occurrence, and network performance metrics to enable quick decision-making.

### 📌 Strategic Recommendations
- **Data-Driven Fraud Detection:** Integrate insights from bandwidth, latency, device, and geolocation patterns into a real-time fraud detection system.
- **Proactive Risk Management:** Allocate resources and adjust network slices based on transaction trends and identified vulnerabilities.
- **Continuous Improvement:** Regularly update KPIs and monitoring rules based on new fraud patterns or network performance metrics.

> Implementing these steps will strengthen **security, operational reliability, and customer trust**, while enabling the bank to **proactively manage fraud risk** and maintain seamless digital transaction processing.

---
## 10. Power BI Dashboard Preview

The Power BI dashboard provides **interactive visualizations** and a clear **storytelling view** of the bank transaction and fraud detection analysis. Key features include:

### 📊 Dashboard Highlights
- **Bank Transaction Report**
  - Total transactions and total transaction amounts
  - Breakdown by transaction type, status, and device
  - Hourly trends and transaction patterns
  - Network performance analysis (Bandwidth Groups)

- **Transaction Details Table**
  - Drill-down view of individual transactions
  - Highlighted fraud flags with conditional formatting
  - Device, network slice, and geolocation information

### 📌 Sample Dashboard Images
<img width="1200" height="700" alt="Bank Transactions Dashboard" src="https://github.com/user-attachments/assets/final_dashboard.png" />

> The dashboard allows analysts and business stakeholders to **interactively explore transaction data**, identify suspicious activity, and monitor network performance for better decision-making.

---
## 11. Conclusion

This analysis of bank transactions and fraud detection provides a **comprehensive view** of digital banking activity, network performance, and risk management.

Key takeaways:

- **Fraud Identification:** The dataset highlights fraudulent transactions, allowing targeted monitoring and proactive prevention.
- **Transaction Trends:** Hourly, device, and transaction-type trends reveal patterns that inform operational decisions.
- **Network Performance:** Bandwidth and latency are critical to ensuring reliable transactions, and monitoring slices enables optimization.
- **Geolocation Insights:** Mapping transactions by latitude and longitude helps identify high-risk regions and unusual patterns.
- **Business Impact:** Implementing the insights and recommendations can reduce financial losses, improve customer trust, and strengthen regulatory compliance.

> By integrating SQL analysis and Power BI visualizations, the bank gains actionable intelligence to **enhance security, optimize network performance, and improve operational efficiency** across digital banking channels.

---

## 12. Appendix — SQL Scripts

All SQL queries used for data preparation, cleaning, KPI calculations, and analysis are included in the project repository:

- `/query/BankTransactions_Cleaning.sql` — Data cleaning and feature engineering
- `/query/BankTransactions_KPIs.sql` — KPI calculations and aggregations
- `/query/FraudDetection_Analysis.sql` — Fraud detection metrics and insights
- `/query/Transaction_Trends.sql` — Temporal and hourly trend analysis
- `/query/Network_Performance.sql` — Bandwidth and latency evaluation
- `/query/Geolocation_Analysis.sql` — Latitude and longitude mapping

> These scripts form the **analytical backbone** for the Power BI visualizations and ensure **reproducible insights** across the dataset.

---

## ✅ Summary

This repository tells a **data-driven story** of bank transactions and fraud detection:

1. **Business Problem:** Increasing digital transactions expose the bank to fraud and operational inefficiencies.
2. **Project Objective:** Analyze transactions, detect fraud, and assess network performance.
3. **Key Insights:** Peak transaction periods, fraud patterns, high-risk devices/slices, and geographic clusters.
4. **Recommendations:** Strengthen authentication, monitor high-risk network slices, optimize bandwidth, and implement proactive fraud detection.
5. **Power BI Dashboard:** Interactive visualizations for decision-making and operational monitoring.

> This analysis equips the bank with **actionable intelligence** to safeguard assets, improve customer trust, and optimize the digital banking experience.

