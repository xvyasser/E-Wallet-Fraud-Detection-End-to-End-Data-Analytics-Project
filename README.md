# 💳 E-Wallet Fraud Detection Dashboard

<div align="center">

## 🚨 End-to-End Fraud Analytics Project  
### PostgreSQL • SQL Feature Engineering • Fraud Scoring • Power BI

**A full-stack analytics project that simulates how a fintech fraud team monitors, scores, and investigates suspicious e-wallet transactions.**

<br>

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Data%20Warehouse-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Fraud%20Scoring-025E8C?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-Data%20Generation-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FinTech](https://img.shields.io/badge/FinTech-Fraud%20Analytics-22C55E?style=for-the-badge)

</div>

---

## 📌 Project Summary

The **E-Wallet Fraud Detection Dashboard** is an end-to-end fraud analytics project designed to detect, score, and investigate suspicious digital wallet transactions.

The project simulates a real fintech fraud intelligence workflow:

```text
Raw E-Wallet Transactions
        ↓
Cleaning & Validation
        ↓
PostgreSQL Data Warehouse
        ↓
Fraud Feature Engineering
        ↓
Fraud Scoring Engine
        ↓
Fraud Alerts
        ↓
Power BI Dashboard
```

The final output is a **6-page Power BI dashboard** that helps executives, fraud analysts, risk teams, and operations teams monitor fraud exposure and investigate high-risk behavior.

---

## 🎯 Business Problem

E-wallet platforms process huge transaction volumes every day. Fraud can appear in many forms:

- ⚡ High transaction velocity
- 🌍 Impossible travel or suspicious location movement
- 📱 Many wallets sharing the same device
- 🏪 Merchant abuse or suspicious merchant behavior
- 💸 Unusually large transaction amounts
- 🕸️ Many receivers in a short time, indicating smurfing or mule activity

Without a centralized fraud dashboard, teams may struggle to answer:

- Which transactions are risky?
- Which wallets should be reviewed first?
- Which merchants are suspicious?
- Where are fraud hotspots concentrated?
- How many alerts are open, high risk, or critical?
- What is the total fraud exposure?

This project solves that by creating a complete fraud analytics workflow from data generation to Power BI reporting.

---

## ✅ Project Objectives

- 🏗️ Build a structured PostgreSQL data warehouse for e-wallet transactions.
- 🧹 Clean, validate, and transform raw transaction data.
- 🧠 Engineer fraud detection features using SQL.
- 🚦 Create an explainable rule-based fraud scoring engine.
- 🚨 Generate fraud alerts for High and Critical transactions.
- ⚡ Build optimized BI views for Power BI performance.
- 📊 Design a professional 6-page Power BI dashboard.
---

## 🧰 Tools & Technologies

| Area | Tools |
|---|---|
| 🐍 Data Generation | Python, Faker |
| 🗄️ Database | PostgreSQL |
| 🛠️ DB Management | pgAdmin |
| 🧱 Data Modeling | Star Schema, Fact & Dimension Tables |
| 🧠 Fraud Logic | SQL, PostgreSQL Procedures, Window Functions |
| ⚡ BI Layer | PostgreSQL Views & Materialized Views |
| 📊 Dashboard | Power BI Desktop |
| 📐 Reporting Logic | DAX Measures, Slicers, KPI Cards |
| 📝 Documentation | GitHub README, PowerPoint Presentation |

---

## 📦 Dataset Overview

The project uses a simulated large-scale e-wallet dataset.

| Entity | Approximate Volume |
|---|---:|
| 👤 Users | 500,000 |
| 🏪 Merchants | 15,000 |
| 💳 Transactions | 48.85M+ |
| 📅 Transaction Period | 2025 |
| 🚦 Risk Bands | Low, Medium, High, Critical |

The dataset includes wallet behavior, merchant activity, device usage, timestamps, locations, transaction amounts, and fraud-related patterns.

---

## 🏛️ Data Architecture

The PostgreSQL database is organized into multiple schemas to keep the project clean and scalable.

```text
staging  → raw and cleaned imported data
ref      → reference and mapping tables
dw       → warehouse fact and dimension tables
fraud    → fraud features, scores, alerts, and risk logic
bi       → reporting-ready views for Power BI
audit    → validation and audit support
```

### 🔁 End-to-End Pipeline

```text
Python Data Generator
        ↓
Raw CSV Files
        ↓
PostgreSQL Staging Tables
        ↓
Cleaning & Validation Layer
        ↓
Data Warehouse Layer
        ↓
Fraud Feature Engineering
        ↓
Fraud Scoring Engine
        ↓
Fraud Alert Generation
        ↓
BI Reporting Views
        ↓
Power BI Dashboard
```

> Heavy data processing is handled in PostgreSQL, while Power BI focuses on reporting, filtering, interactivity, and storytelling.

---

## 🧱 Data Warehouse Design

The warehouse follows a star-schema style design.

### Main Fact Table

| Table | Description |
|---|---|
| `dw.fact_transaction` | Cleaned and validated transaction-level records |

### Dimension Tables

| Table | Description |
|---|---|
| `dw.dim_user` | User and wallet information |
| `dw.dim_merchant` | Merchant profile and category details |
| `dw.dim_device` | Device information |
| `bi.dim_date` | Calendar table for date filtering |
| `bi.dim_risk_band` | Risk band dimension for dashboard filtering |

---

## 🧠 Fraud Feature Engineering

Fraud features were created using SQL and PostgreSQL window functions.

### ⚡ Velocity Risk

Detects abnormal activity in short time windows.

Examples:

- Transactions in 15 minutes
- Transactions in 1 hour
- Amount sent in 1 hour

### 🌍 Geographic Risk

Detects impossible or suspicious movement.

Examples:

- Distance from previous transaction
- Minutes since previous transaction
- Long-distance movement in a short time

### 📱 Device Risk

Detects shared-device behavior.

Examples:

- Number of wallets linked to the same device
- Device reuse across many users

### 🏪 Merchant Risk

Detects suspicious merchant behavior.

Examples:

- Merchant failed transaction rate
- Merchant flagged transaction rate
- Merchant risk index

### 💸 Amount Risk

Detects unusually large transaction values.

Examples:

- Large individual transaction amount
- High total amount within one hour

### 🕸️ Receiver Behavior

Detects smurfing-like patterns.

Examples:

- Many unique receivers within one hour
- Wallets sending money to multiple receivers quickly

---

## 🚦 Fraud Scoring Logic

Each transaction receives component scores based on suspicious behavior.

| Component | Meaning |
|---|---|
| `velocity_score` | High transaction count or amount in short time |
| `geo_score` | Suspicious location movement |
| `device_score` | Shared-device risk |
| `merchant_score` | Merchant-level risk indicators |
| `amount_score` | Unusually large transactions |
| `receiver_score` | Many receivers in a short time |

The final fraud score is calculated by combining the component scores.

```text
Final Fraud Score =
Velocity Score
+ Geo Score
+ Device Score
+ Merchant Score
+ Amount Score
+ Receiver Score
```

### Risk Band Classification

| Risk Band | Meaning |
|---|---|
| 🟢 Low | Normal or low-risk behavior |
| 🟡 Medium | Suspicious behavior that may require monitoring |
| 🟠 High | Strong fraud signals requiring review |
| 🔴 Critical | Severe risk requiring immediate attention |

High and Critical transactions are converted into fraud alerts.

---

## 🚨 Fraud Alert Logic

Fraud alerts are generated from transactions where:

```sql
risk_band IN ('High', 'Critical')
```

Each alert includes:

- Transaction ID
- Sender wallet ID
- Merchant ID
- Device ID
- Fraud score
- Risk band
- Alert reason
- Alert status
- Transaction date
- Alert priority sort

### Alert Reasons

| Alert Reason | Meaning |
|---|---|
| 🌍 Impossible Travel | Suspicious geographic movement |
| 🕸️ Smurfing Behavior | Many receivers in a short time |
| 📱 Shared Device Ring | Many wallets linked to one device |
| 🏪 Merchant Abuse | Suspicious merchant behavior |
| ⚡ High Velocity Behavior | Too many transactions too quickly |
| 💸 Unusual Transaction Amount | Large transaction value |

---

## ⚡ BI Reporting Layer

Power BI connects to curated BI views instead of raw transaction tables.

| BI View | Purpose |
|---|---|
| `bi.fact_daily_fraud_kpi` | Daily fraud KPIs for executive reporting |
| `bi.alert_queue` | Alert-level investigation table |
| `bi.high_risk_transactions` | High and Critical transaction details |
| `bi.merchant_risk_summary` | Merchant-level fraud risk summary |
| `bi.user_risk_summary` | Wallet and customer risk summary |
| `bi.risk_band_distribution` | Overall risk band distribution |
| `bi.dim_date` | Date filtering |
| `bi.dim_risk_band` | Risk band filtering |

This keeps the Power BI report fast and avoids scanning the full raw transaction dataset.

---

## 📊 Power BI Dashboard Pages

The final dashboard contains six pages.

---

### 1️⃣ Executive Fraud Overview

**Purpose:** Provide leadership with a high-level view of fraud exposure.

**Key KPIs:**

- Total Transactions
- Total Amount
- Flagged Transactions
- Flagged Rate
- Flagged Amount
- Critical Risk Transactions

**Main Visuals:**

- KPI cards
- Fraud trend line
- High vs Critical chart
- Risk band distribution

---

### 2️⃣ Fraud Ops Center

**Purpose:** Help fraud analysts monitor alerts and prioritize investigations.

**Key KPIs:**

- Total Alerts
- Open Alerts
- High Alerts
- Critical Alerts

**Main Visuals:**

- Alerts by reason
- Alert detail table
- Risk band slicers
- Main reason slicers

---

### 3️⃣ Merchant Risk Analysis

**Purpose:** Identify risky merchants and suspicious merchant categories.

**Key Metrics:**

- Transaction Count
- Total Amount
- Flagged Transaction Count
- Flagged Rate
- Average Fraud Score
- Merchant Risk Index

**Main Visuals:**

- Merchant risk scatter plot
- Top flagged merchants
- Top risky categories
- Merchant detail table

---

### 4️⃣ User & Device Risk

**Purpose:** Identify risky wallets, suspicious customers, and device-sharing patterns.

**Key Metrics:**

- Wallet Fraud Score
- Transaction Count
- Device Count
- Receiver Count
- Flagged Rate
- Total Amount

**Main Visuals:**

- Top risky wallets
- Receivers vs flagged rate scatter plot
- Wallet/device detail table
- KYC and account status slicers

---

### 5️⃣ Geospatial Fraud Analysis

**Purpose:** Show geographic concentration of suspicious activity.

**Key Metrics:**

- Transactions by governorate
- Flagged rate by governorate
- Critical cases
- Fraud hotspot ranking

**Main Visuals:**

- Map visual
- Governorate risk ranking
- Critical concentration
- Hotspot table

---

### 6️⃣ Alert Investigation

**Purpose:** Support alert triage and investigation workflow.

**Key Metrics:**

- Open Alerts
- Closed Alerts
- Total Alerts
- Average Resolution Time
- SLA Breaches

**Main Visuals:**

- Alert queue
- Alert status cards
- Alerts over time
- Backlog summary

---

## 🧮 Key DAX Measures

```DAX
Total Transactions =
SUM ( 'Daily Fraud KPI'[transaction_count] )
```

```DAX
Flagged Transactions =
SUM ( 'Daily Fraud KPI'[flagged_transaction_count] )
```

```DAX
Flagged Rate =
DIVIDE ( [Flagged Transactions], [Total Transactions] )
```

```DAX
Total Alerts =
COUNTROWS ( 'Alert Queue' )
```

```DAX
Open Alerts =
CALCULATE (
    [Total Alerts],
    'Alert Queue'[alert_status] = "Open"
)
```

```DAX
High Alerts =
CALCULATE (
    [Total Alerts],
    'Alert Queue'[risk_band] = "High"
)
```

```DAX
Critical Alerts =
CALCULATE (
    [Total Alerts],
    'Alert Queue'[risk_band] = "Critical"
)
```

---

## 🔍 Validation Process

Dashboard results were validated against PostgreSQL queries.

Validation checks included:

- Total transaction count
- Monthly transaction distribution
- Risk band distribution
- Alert count
- Alerts by reason
- Merchant-level metrics
- Wallet-level metrics
- Date slicer behavior
- Risk band slicer behavior
- Visual interaction testing

This ensured that Power BI visuals matched the PostgreSQL reporting layer.

---

## 🎨 Dashboard Design Principles

The dashboard was designed with a dark fintech fraud-ops theme.

### Color Logic

| Risk Level | Color |
|---|---|
| 🟢 Low | Green / Teal |
| 🟡 Medium | Yellow |
| 🟠 High | Orange |
| 🔴 Critical | Red |

### Design Choices

- KPI cards for executive metrics
- Line charts for trends
- Bar charts for rankings
- Scatter plots for risk positioning
- Tables for investigation details
- Slicers for interactivity
- Curated BI views for performance

---

## 💼 Business Impact

### 👔 Managers

Use the Executive Overview page to monitor fraud exposure, flagged rates, critical volumes, and platform-level trends.

### 🕵️ Fraud Analysts

Use the Fraud Ops Center and Alert Investigation pages to prioritize alerts and investigate high-risk transactions.

### 🧠 Risk Teams

Use Merchant Risk, User & Device Risk, and Geospatial Analysis pages to identify suspicious merchants, risky wallets, and fraud hotspots.

### ⚙️ Operations Teams

Use alert workload and investigation views to monitor open cases, backlog, and operational priorities.

---

## 🏆 Project Achievements

This project successfully delivered:

- ✅ Large-scale simulated e-wallet transaction dataset
- ✅ PostgreSQL data warehouse
- ✅ SQL-based fraud feature engineering
- ✅ Explainable fraud scoring engine
- ✅ Fraud alert generation logic
- ✅ Curated BI reporting views
- ✅ Professional 6-page Power BI dashboard
- ✅ KPI validation against database queries
- ✅ Portfolio-ready fraud analytics case study

---
## 🚀 Final Result

**A complete fraud analytics solution that transforms raw e-wallet transactions into actionable fraud intelligence.**

</div>
