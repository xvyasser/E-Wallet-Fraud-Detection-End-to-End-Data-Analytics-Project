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

## 📎 Notes

The raw generated dataset is not included in this repository due to file size.  
The repository focuses on the project logic, SQL pipeline, Power BI dashboard, screenshots, and documentation.

---

<div align="center">

## 🚀 Final Result

**A complete fraud analytics solution that transforms raw e-wallet transactions into actionable fraud intelligence.**

</div>
