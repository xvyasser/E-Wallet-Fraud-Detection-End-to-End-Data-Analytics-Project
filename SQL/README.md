# 🧠 SQL Pipeline README — E-Wallet Fraud Detection Project

<div align="center">

## 🗄️ PostgreSQL Data Warehouse • Fraud Feature Engineering • Fraud Scoring • BI Views

**This folder contains the SQL backbone of the E-Wallet Fraud Detection Dashboard project.**  
It documents the database schemas, execution order, major SQL objects, validation checks, and the key problems solved during development.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Data%20Warehouse-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Fraud%20Engineering-025E8C?style=for-the-badge)
![Power BI](https://img.shields.io/badge/Power%20BI-Reporting%20Layer-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Fraud Analytics](https://img.shields.io/badge/Fraud%20Analytics-Rule%20Based%20Scoring-DC2626?style=for-the-badge)

</div>

---

## 📌 Folder Purpose

The `sql/` folder contains all database logic used to turn raw e-wallet transaction data into a clean, scored, and dashboard-ready fraud analytics model.

The SQL pipeline covers:

- 🏗️ Schema creation
- 🧹 Staging, cleaning, and validation
- 🧱 Data warehouse fact/dimension modeling
- 🧠 Fraud feature engineering
- 🚦 Fraud scoring and risk banding
- 🚨 Fraud alert generation
- ⚡ Materialized views and BI views for Power BI

---

## 🧭 High-Level SQL Pipeline

```text
Raw CSV Data
    ↓
staging schema
    ↓
cleaning + validation
    ↓
dw schema
    ↓
fraud feature engineering
    ↓
fraud scoring
    ↓
fraud alerts
    ↓
materialized views
    ↓
bi schema
    ↓
Power BI Dashboard
```

---

## 🏛️ Database Schema Design

The PostgreSQL database is divided into schemas to separate responsibilities clearly.

| Schema | Purpose |
|---|---|
| `staging` | Raw and cleaned imported data |
| `ref` | Reference and mapping tables |
| `dw` | Data warehouse fact and dimension tables |
| `fraud` | Fraud features, risk scoring, alerts, and analytical logic |
| `bi` | Power BI reporting views and dimensions |
| `audit` | Validation and auditing support |

---


## 🧱 Core Tables and Objects

### 1️⃣ Staging Layer

| Object | Purpose |
|---|---|
| `staging.raw_transactions` | Raw imported transaction data |
| `staging.clean_transactions_work` | Cleaned and validated transaction work table |
| `staging.raw_users` | Raw user data |
| `staging.raw_merchants` | Raw merchant data |
| `staging.raw_devices` | Raw device data |

The staging layer is where messy data is parsed, validated, and prepared before entering the warehouse.

---

### 2️⃣ Reference Layer

| Object | Purpose |
|---|---|
| `ref.transaction_type_map` | Standardizes transaction types |
| `ref.transaction_status_map` | Standardizes transaction statuses |
| `ref.category_map` | Standardizes merchant categories |

The reference layer makes inconsistent raw values usable for analytics.

---

### 3️⃣ Data Warehouse Layer

| Object | Purpose |
|---|---|
| `dw.dim_user` | User and wallet dimension |
| `dw.dim_merchant` | Merchant dimension |
| `dw.dim_device` | Device dimension |
| `dw.fact_transaction` | Main transaction fact table |

The warehouse layer stores validated, analysis-ready data.

---

### 4️⃣ Fraud Analytics Layer

| Object | Purpose |
|---|---|
| `fraud.transaction_features` | Transaction-level engineered fraud features |
| `fraud.transaction_fraud_scores` | Final fraud scores, risk bands, and main reasons |
| `fraud.fraud_alerts` | Alert table generated from High and Critical transactions |
| `fraud.device_risk_base` | Device-level risk support table |
| `fraud.merchant_risk_base` | Merchant-level failed-rate support table |
| `fraud.sender_hourly_receiver_counts` | Sender-to-receiver behavior support table |

---

### 5️⃣ BI Reporting Layer

| Object | Purpose |
|---|---|
| `bi.fact_daily_fraud_kpi` | Daily executive fraud KPIs |
| `bi.alert_queue` | Alert investigation view |
| `bi.high_risk_transactions` | High and Critical transaction details |
| `bi.merchant_risk_summary` | Merchant-level risk analytics |
| `bi.user_risk_summary` | Wallet and customer risk analytics |
| `bi.risk_band_distribution` | Overall risk band distribution |
| `bi.dim_date` | Calendar dimension |
| `bi.dim_risk_band` | Risk band dimension |

Power BI connects mainly to the `bi` schema, not the raw 48M+ transaction fact table.

---

# ⚙️ Main SQL Workflow

## Step 1 — Create Schemas

```sql
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS ref;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS fraud;
CREATE SCHEMA IF NOT EXISTS bi;
CREATE SCHEMA IF NOT EXISTS audit;
```

---

## Step 2 — Load and Clean Staging Data

Raw data is loaded into staging tables, then parsed and validated into:

```sql
staging.clean_transactions_work
```

Validation includes:

- timestamp parsing
- amount parsing
- latitude / longitude validation
- transaction status normalization
- duplicate handling
- invalid-row separation

---

## Step 3 — Load Dimensions

Dimension tables standardize entities used by the transaction fact table:

```text
dw.dim_user
dw.dim_merchant
dw.dim_device
```

These tables support star-schema modeling and cleaner Power BI relationships.

---

## Step 4 — Load Fact Transactions

The central warehouse table is:

```sql
dw.fact_transaction
```

It stores cleaned transactions with keys to users, merchants, and devices.

Important fact fields include:

- `transaction_id`
- `sender_wallet_id`
- `receiver_wallet_id`
- `merchant_id`
- `device_id`
- `transaction_type`
- `transaction_status`
- `transaction_amount`
- `transaction_ts`
- `transaction_date`
- `latitude`
- `longitude`
- `channel`

---

## Step 5 — Build Fraud Features

Fraud features are stored in:

```sql
fraud.transaction_features
```

Key engineered features:

| Feature | Meaning |
|---|---|
| `txn_count_15m` | Number of sender transactions in the last 15 minutes |
| `txn_count_1h` | Number of sender transactions in the last hour |
| `amount_sum_1h` | Amount sent by sender in the last hour |
| `unique_receivers_1h` | Unique receivers contacted by sender in the last hour |
| `distance_from_previous_txn_km` | Distance from previous transaction |
| `minutes_since_previous_txn` | Time since previous transaction |
| `wallets_per_device` | Number of wallets linked to the same device |
| `merchant_failed_rate` | Merchant failed transaction rate |

---

## Step 6 — Score Transactions

Fraud scores are stored in:

```sql
fraud.transaction_fraud_scores
```

Component scores include:

| Score | Purpose |
|---|---|
| `velocity_score` | High transaction count / amount in short time |
| `geo_score` | Impossible travel or suspicious location movement |
| `device_score` | Shared device behavior |
| `merchant_score` | Suspicious merchant behavior |
| `amount_score` | Large transaction amount |
| `receiver_score` | Many receivers in short time |

Final score:

```text
fraud_score =
velocity_score
+ geo_score
+ device_score
+ merchant_score
+ amount_score
+ receiver_score
```

Risk bands:

| Risk Band | Meaning |
|---|---|
| 🟢 Low | Normal / low risk |
| 🟡 Medium | Suspicious but not urgent |
| 🟠 High | Strong fraud signals |
| 🔴 Critical | Severe fraud risk |

---

## Step 7 — Generate Alerts

Alerts are generated from:

```sql
risk_band IN ('High', 'Critical')
```

Alert reasons include:

- 🌍 Impossible travel
- 🕸️ Smurfing behavior
- 📱 Shared device ring
- 🏪 Merchant abuse
- ⚡ High velocity behavior
- 💸 Unusual transaction amount

Main alert table:

```sql
fraud.fraud_alerts
```

BI view used in Power BI:

```sql
bi.alert_queue
```

---

## Step 8 — Refresh Materialized Views and BI Views

Materialized views improve reporting performance.

Main materialized views:

```sql
REFRESH MATERIALIZED VIEW fraud.mv_daily_fraud_summary;
REFRESH MATERIALIZED VIEW fraud.mv_merchant_risk_summary;
REFRESH MATERIALIZED VIEW fraud.mv_user_risk_summary;
REFRESH MATERIALIZED VIEW fraud.mv_high_risk_transactions;
```

BI views expose clean tables to Power BI:

```text
bi.fact_daily_fraud_kpi
bi.alert_queue
bi.merchant_risk_summary
bi.user_risk_summary
bi.high_risk_transactions
bi.risk_band_distribution
```

---

# 🧯 Problems Solved During Development

This section documents the major issues encountered during the SQL build and how they were solved.

---

## 🧨 Problem 1 — Fact Table Loaded Only One Month

### What Happened

After loading multiple months, the fact table only contained the latest month.

### Root Cause

The monthly loader procedure contained:

```sql
TRUNCATE TABLE dw.fact_transaction RESTART IDENTITY CASCADE;
```

inside the procedure.

That meant every monthly load deleted the previous months.

### Fix

Removed the `TRUNCATE` from the monthly load procedure.

### Lesson Learned

> Never put a full-table `TRUNCATE` inside a monthly incremental load procedure.

---

## 📅 Problem 2 — Date Dimension Only Showed December

### What Happened

Power BI date slicers only showed December.

### Root Cause

`bi.dim_date` was generated from the fact table when the fact table only contained December data.

### Fix

Created a fixed calendar table for the full year 2025.

```sql
DROP TABLE IF EXISTS bi.dim_date CASCADE;

CREATE TABLE bi.dim_date AS
SELECT
    d::date AS date_key,
    EXTRACT(YEAR FROM d)::int AS year,
    EXTRACT(MONTH FROM d)::int AS month_number,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    TO_CHAR(d, 'YYYY-MM') AS year_month,
    EXTRACT(WEEK FROM d)::int AS week_number,
    TO_CHAR(d, 'IYYY-"W"IW') AS year_week,
    EXTRACT(DOW FROM d)::int AS day_of_week_number,
    TRIM(TO_CHAR(d, 'Day')) AS day_of_week_name
FROM GENERATE_SERIES(
    '2025-01-01'::date,
    '2026-01-01'::date,
    INTERVAL '1 day'
) AS d
WHERE d::date < '2026-01-01'::date;

ALTER TABLE bi.dim_date
ADD CONSTRAINT pk_dim_date PRIMARY KEY (date_key);
```

### Lesson Learned

> Date dimensions should be fixed calendar tables, not generated only from existing fact data.

---

## 🐢 Problem 3 — Fraud Feature Procedure Ran for Too Long

### What Happened

The fraud feature procedure ran for many hours.

### Root Cause

The window-function query was processing too much data at once.

### Fix

Processed features month by month and corrected the filtering logic.


```

### Lesson Learned

> Large window-function workloads should be processed in controlled monthly batches.

---

## 🎯 Problem 4 — Initial Fraud Scoring Was Too Conservative

### What Happened

The first scoring logic generated very few alerts.

Example symptoms:

```text
High/Critical alerts were almost nonexistent.
Critical risk was nearly impossible to reach.
```

### Root Cause

The original thresholds were too high for the generated transaction behavior.

### Fix

Recalibrated score components and risk bands.

New component scoring included:

- stronger velocity scoring
- geo anomaly scoring
- shared device scoring
- merchant failed-rate scoring
- amount scoring
- receiver behavior scoring

### Lesson Learned

> Fraud scoring thresholds must be calibrated against the actual data distribution.

---


## 📉 Problem 5 — Materialized Views Suddenly Became Small

### What Happened

Materialized views showed very few alerts.

### Root Cause

The scoring engine became too strict showing very few alerts.

### Fix

Adjusted risk-band thresholds to make alerts realistic again.

Example risk-band logic:

```sql
CASE
    WHEN fraud_score >= 61 THEN 'Critical'
    WHEN fraud_score >= 41 THEN 'High'
    WHEN fraud_score >= 26 THEN 'Medium'
    ELSE 'Low'
END AS risk_band
```

### Lesson Learned

> Removing artificial signals requires recalibrating thresholds.

---


# 🚀 Final SQL Outcome

The SQL layer successfully delivered:

- ✅ Clean staging and validation pipeline
- ✅ PostgreSQL data warehouse
- ✅ Fact and dimension tables
- ✅ Fraud feature engineering
- ✅ Explainable scoring engine
- ✅ Fraud alert generation
- ✅ Materialized views for reporting performance
- ✅ BI views for Power BI
- ✅ Debugged and validated SQL pipeline
- ✅ Production-style separation of schemas and responsibilities

---

<div align="center">

## 🏁 SQL Layer Summary

**This SQL pipeline transforms raw e-wallet transaction data into fraud intelligence ready for Power BI dashboards.**

</div>
