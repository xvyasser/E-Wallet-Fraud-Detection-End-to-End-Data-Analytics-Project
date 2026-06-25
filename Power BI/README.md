# 📊 Power BI Folder README — E-Wallet Fraud Detection Dashboard

<div align="center">

## 💳 Fraud Monitoring • Executive KPIs • Risk Investigation • FinTech BI

**This folder contains the Power BI dashboard, report theme, screenshots, and dashboard-specific documentation for the E-Wallet Fraud Detection project.**

![Power BI](https://img.shields.io/badge/Power%20BI-Fraud%20Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-Measures%20%26%20KPIs-FFB000?style=for-the-badge)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-BI%20Views-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Dashboard](https://img.shields.io/badge/Dashboard-6%20Pages-22C55E?style=for-the-badge)
![Fraud Ops](https://img.shields.io/badge/Fraud%20Ops-Alert%20Monitoring-DC2626?style=for-the-badge)

</div>

---

## 📌 Folder Purpose

The `powerbi/` folder contains the business intelligence layer of the project.

This is where the PostgreSQL fraud pipeline becomes a professional dashboard used for:

- 👔 Executive fraud monitoring
- 🕵️ Fraud analyst investigation
- 🏪 Merchant risk analysis
- 👤 Wallet and device risk review
- 🌍 Geographic fraud hotspot detection
- 🚨 Alert queue monitoring

Power BI connects to curated `bi` schema views from PostgreSQL instead of raw transaction tables.

---

## 📂 Recommended Folder Contents

```text
powerbi/
│
├── EWallet_Fraud_Detection_Dashboard.pbix
├── ewallet_fraud_detection_powerbi_theme.json
├── README.md
│
└── exports/
    ├── EWallet_Fraud_Detection_Dashboard.pdf
    └── screenshots/
        ├── page_1_executive_overview.png
        ├── page_2_fraud_ops_center.png
        ├── page_3_merchant_risk.png
        ├── page_4_user_device_risk.png
        ├── page_5_geospatial_analysis.png
        └── page_6_alert_investigation.png
```

> If the `.pbix` file is larger than GitHub's upload limit, keep screenshots and documentation in the repository and mention that the PBIX file is available separately.

---

## 🧭 Dashboard Architecture

```text
PostgreSQL BI Schema
        ↓
Power BI Data Model
        ↓
DAX Measures
        ↓
Interactive Dashboard Pages
        ↓
Business Users
```

Power BI was intentionally connected to reporting-ready views instead of raw data.

This improves:

- ⚡ report performance
- 🧠 model simplicity
- 🔍 validation accuracy
- 🧩 relationship management
- 📊 dashboard usability

---

## 🗄️ PostgreSQL Views Used in Power BI

Power BI connects mainly to the `bi` schema.

| View / Table | Purpose |
|---|---|
| `bi.fact_daily_fraud_kpi` | Daily executive fraud KPIs |
| `bi.alert_queue` | Fraud alert investigation queue |
| `bi.high_risk_transactions` | High and Critical transaction details |
| `bi.merchant_risk_summary` | Merchant-level risk metrics |
| `bi.user_risk_summary` | Wallet and customer-level risk metrics |
| `bi.risk_band_distribution` | Overall risk band distribution |
| `bi.dim_date` | Date dimension for slicers and trends |
| `bi.dim_risk_band` | Risk band dimension for filtering |

---

## 🔗 Power BI Model Relationships

The dashboard uses a clean relationship model based on date and risk-band dimensions.

Recommended relationships:

```text
bi.dim_date[date_key] 1 → * bi.fact_daily_fraud_kpi[date_key]

bi.dim_date[date_key] 1 → * bi.high_risk_transactions[date_key]

bi.dim_date[date_key] 1 → * bi.alert_queue[transaction_date]

bi.dim_risk_band[risk_band] 1 → * bi.high_risk_transactions[risk_band]

bi.dim_risk_band[risk_band] 1 → * bi.alert_queue[risk_band]
```

Important design note:

```text
Use transaction_date for alert analysis,
not created_date.
```

This makes alert visuals reflect the actual fraud transaction date.

---

## 📊 Dashboard Pages

The report contains six pages, each designed for a specific business use case.

---

# 1️⃣ Executive Fraud Overview

## 🎯 Purpose

Provides managers and executives with a high-level fraud summary.

## 👥 Target Users

- Executives
- BI managers
- Fraud leadership
- Risk management teams

## 📌 Key Questions

- How many transactions were processed?
- How much money moved through the platform?
- How many transactions were flagged?
- What is the flagged transaction rate?
- How many transactions are Critical risk?
- Is fraud activity increasing or decreasing over time?

## 🧮 Main KPIs

| KPI | Meaning |
|---|---|
| Total Transactions | Total transaction volume |
| Total Amount | Total transaction value |
| Flagged Transactions | High and Critical risk transactions |
| Flagged Rate | Percentage of transactions flagged |
| Flagged Amount | Value of flagged transactions |
| Critical Transactions | Severe risk transactions |

## 📈 Main Visuals

- KPI cards
- Fraud trend line
- Risk band distribution
- High vs Critical chart
- Date slicer
- Transaction type / governorate filters

---

# 2️⃣ Fraud Ops Center

## 🎯 Purpose

Helps fraud analysts monitor alerts and prioritize suspicious transactions.

## 👥 Target Users

- Fraud analysts
- Investigation teams
- Operations teams

## 📌 Key Questions

- How many alerts are open?
- How many alerts are High or Critical?
- What are the most common alert reasons?
- Which transactions require immediate review?
- Which risk bands dominate the alert queue?

## 🧮 Main KPIs

| KPI | Meaning |
|---|---|
| Total Alerts | Total generated fraud alerts |
| Open Alerts | Alerts still requiring review |
| High Alerts | High-risk alerts |
| Critical Alerts | Highest-priority alerts |

## 📈 Main Visuals

- Alert KPI cards
- Alerts by reason
- Alerts over time
- Alert detail table
- Risk band slicer
- Main reason slicer

---

# 3️⃣ Merchant Risk Analysis

## 🎯 Purpose

Identifies risky merchants, suspicious categories, and merchant-level fraud exposure.

## 👥 Target Users

- Merchant risk teams
- Fraud analysts
- Risk operations
- Business teams reviewing merchant quality

## 📌 Key Questions

- Which merchants are most suspicious?
- Which merchants combine high volume and high risk?
- Which merchant categories are riskier?
- Which merchants should be reviewed first?

## 🧮 Main Metrics

| Metric | Meaning |
|---|---|
| Transaction Count | Total merchant transactions |
| Total Amount | Total transaction value |
| Flagged Transactions | Merchant's flagged transaction count |
| Flagged Rate | Percentage of merchant transactions flagged |
| Average Fraud Score | Average transaction risk |
| Merchant Risk Index | Composite merchant risk metric |

## 📈 Main Visuals

- Merchant risk scatter plot
- Top flagged merchants
- Risky category ranking
- Merchant detail table
- Merchant/category slicers

## 🧠 Merchant Risk Index

The merchant risk index combines:

- flagged rate
- critical rate
- average fraud score
- merchant failed rate

This creates a stronger merchant ranking metric than flagged rate alone.

---

# 4️⃣ User & Device Risk

## 🎯 Purpose

Surfaces risky wallets, suspicious users, and shared-device behavior.

## 👥 Target Users

- Fraud analysts
- Customer risk teams
- Investigation teams

## 📌 Key Questions

- Which wallets have the highest fraud score?
- Which wallets have abnormal receiver behavior?
- Which users are connected to many devices?
- Which devices are shared by many wallets?
- Which wallets should be investigated first?

## 🧮 Main Metrics

| Metric | Meaning |
|---|---|
| Max Fraud Score | Highest score reached by a wallet |
| Transaction Count | Wallet activity volume |
| Device Count | Number of devices linked to wallet |
| Receiver Count | Number of unique receivers |
| Flagged Rate | Percentage of risky wallet transactions |
| Total Amount | Total wallet transaction value |

## 📈 Main Visuals

- Top risky wallets
- Wallet behavior scatter plot
- Wallet/device detail table
- KYC status slicer
- Account status slicer

---

# 5️⃣ Geospatial Fraud Analysis

## 🎯 Purpose

Shows where suspicious activity is geographically concentrated.

## 👥 Target Users

- Risk teams
- Strategy teams
- Fraud managers
- Regional operations teams

## 📌 Key Questions

- Which governorates have the most suspicious activity?
- Where are Critical cases concentrated?
- Are fraud hotspots clustered in specific regions?
- Which locations need closer monitoring?

## 🧮 Main Metrics

| Metric | Meaning |
|---|---|
| Transactions by Governorate | Total transaction activity per area |
| Flagged Rate | Fraud concentration by area |
| Critical Cases | Severe fraud count by area |
| Hotspot Rank | Geographic fraud priority |

## 📈 Main Visuals

- Map visual
- Governorate ranking
- Critical case concentration
- Fraud hotspot table
- Governorate slicer

---

# 6️⃣ Alert Investigation

## 🎯 Purpose

Supports alert triage, prioritization, and investigation workflow.

## 👥 Target Users

- Fraud operations
- Investigation teams
- Alert reviewers
- Risk monitoring teams

## 📌 Key Questions

- Which alerts are open?
- Which alerts are highest priority?
- What is the current alert workload?
- Which transactions need immediate review?
- How are alerts distributed over time?

## 🧮 Main Metrics

| Metric | Meaning |
|---|---|
| Open Alerts | Alerts awaiting review |
| Closed Alerts | Reviewed alerts |
| Total Alerts | Total fraud alerts |
| Average Resolution Time | Time to resolve cases |
| SLA Breaches | Alerts exceeding expected handling time |

## 📈 Main Visuals

- Alert queue table
- Alert status cards
- Alerts over time
- Alert backlog summary
- Priority sorting

---

## 🧮 Key DAX Measures

These are the main measures used across the Power BI report.

---

## Total Transactions

```DAX
Total Transactions =
SUM ( 'Daily Fraud KPI'[transaction_count] )
```

---

## Total Amount

```DAX
Total Amount =
SUM ( 'Daily Fraud KPI'[total_amount] )
```

---

## Flagged Transactions

```DAX
Flagged Transactions =
SUM ( 'Daily Fraud KPI'[flagged_transaction_count] )
```

---

## Flagged Rate

```DAX
Flagged Rate =
DIVIDE ( [Flagged Transactions], [Total Transactions] )
```

---

## Flagged Amount

```DAX
Flagged Amount =
SUM ( 'Daily Fraud KPI'[flagged_amount] )
```

---

## Total Alerts

```DAX
Total Alerts =
COUNTROWS ( 'Alert Queue' )
```

---

## Open Alerts

```DAX
Open Alerts =
CALCULATE (
    [Total Alerts],
    'Alert Queue'[alert_status] = "Open"
)
```

---

## High Alerts

```DAX
High Alerts =
CALCULATE (
    [Total Alerts],
    'Alert Queue'[risk_band] = "High"
)
```

---

## Critical Alerts

```DAX
Critical Alerts =
CALCULATE (
    [Total Alerts],
    'Alert Queue'[risk_band] = "Critical"
)
```

---

## 🎨 Dashboard Theme

The dashboard uses a dark fintech fraud-operations theme.

### Color Logic

| Risk Level | Color Meaning |
|---|---|
| 🟢 Low | Safe / low risk |
| 🟡 Medium | Watchlist / suspicious |
| 🟠 High | Strong risk signal |
| 🔴 Critical | Immediate investigation |

### Design Style

- Dark navy background
- Teal and cyan highlights
- Orange and red for risk severity
- KPI cards for summary numbers
- Clean tables for investigation
- Consistent slicers across pages
- Minimal visual clutter
- Fraud-ops command-center feeling

---

## 🧩 Power BI Problems Solved

This section documents the main Power BI issues encountered and how they were solved.

---

# 🧨 Problem 1 — Date Slicer Only Showed December

## What Happened

The date slicer only displayed December.

## Root Cause

The date dimension was generated from the fact table when the fact table only had December data.

## Fix

Created a full physical date table for 2025 in PostgreSQL and used it as `bi.dim_date`.

## Lesson Learned

> A proper BI date dimension should be a fixed calendar table, not dependent only on currently loaded fact rows.

---

# 🔗 Problem 2 — Date Slicer Did Not Filter Alert Visuals

## What Happened

The same alert numbers appeared across multiple days or months.

## Root Cause

The date table was not correctly related to the alert table.

## Fix

Used this relationship:

```text
bi.dim_date[date_key] 1 → * bi.alert_queue[transaction_date]
```

instead of using `created_date`.

## Lesson Learned

> Alert analysis should usually follow the transaction date, not the alert creation date.

---

# 🧩 Problem 3 — Risk Band Slicer Filtered Some Visuals but Not All

## What Happened

The Risk Band slicer affected some visuals but not others.

## Root Cause

Some visuals used tables related to `bi.dim_risk_band`, while others used independent summary tables.

## Fix

Used the correct related fields per visual and accepted that not every slicer should control every page visual.

## Lesson Learned

> Slicers only filter visuals when there is a valid relationship path or when the slicer field exists in the same table.

---

# 🧱 Problem 4 — Power BI Expected Missing Column `alert_priority_sort`

## What Happened

Power BI refresh failed because `alert_priority_sort` was missing.

## Root Cause

Power BI had imported the column earlier, but the SQL view was later recreated without it.

## Fix

Added the column back to `bi.alert_queue`.

```sql
CASE
    WHEN risk_band = 'Critical' THEN 1
    WHEN risk_band = 'High' THEN 2
    WHEN risk_band = 'Medium' THEN 3
    WHEN risk_band = 'Low' THEN 4
    ELSE 5
END AS alert_priority_sort
```

## Lesson Learned

> Once Power BI imports a table, changing the source schema can break refresh.

---

# 🏪 Problem 5 — Merchant Scatter Plot Looked Flat

## What Happened

The merchant scatter plot showed bubbles clustered in a narrow band.

## Root Cause

`flagged_rate` had a very narrow distribution, so it was not strong enough for the Y-axis.

## Fix

Created and used:

```text
merchant_risk_index
```

as the Y-axis.

## Lesson Learned

> A scatter plot needs meaningful spread across both axes. A composite metric can make visual positioning more useful.

---

# ⚪ Problem 6 — Scatter Plot Went Blank

## What Happened

After adding `merchant_risk_index`, the scatter plot went blank.

## Root Cause

Power BI treated the field as non-numeric or invalid for the axis.

## Fix

Changed the field type to:

```text
Decimal Number
```

and re-added it to the visual.

## Lesson Learned

> Power BI scatter plot X and Y axes must be numeric fields.

---

# 🧮 Problem 7 — Top 5 Wallets Visual Was Confusing

## What Happened

The user was trying to filter top wallets but was using the Filters pane incorrectly.

## Fix

Used a bar chart with:

```text
Y-axis  → sender_wallet_id
X-axis  → max_fraud_score
Filter  → Top N = Top 5 by max_fraud_score
Sort    → Descending
```

## Lesson Learned

> Top N visuals need a category field and a numeric ranking measure.

---

# 🧊 Problem 8 — Power BI Refresh Failed After View Changes

## What Happened

Power BI expected old columns after SQL views were recreated.

## Root Cause

Power BI stores metadata for imported source columns.

## Fix Options

- Add the missing column back into the SQL view.
- Refresh Preview in Power Query.
- Remove and re-import the table if the model should change.
- Keep source view schemas stable once the dashboard is built.

## Lesson Learned

> BI source schemas should be treated like contracts.

---

## 🔍 Dashboard Validation Checklist

Use this checklist before publishing or pushing screenshots to GitHub.

### Executive Page

- [ ] Total transactions match PostgreSQL.
- [ ] Total amount matches PostgreSQL.
- [ ] Flagged transactions match High + Critical transactions.
- [ ] Flagged rate = flagged transactions / total transactions.
- [ ] Date slicer filters trend visuals.
- [ ] Risk band distribution matches SQL.

### Fraud Ops Page

- [ ] Total alerts match `fraud.fraud_alerts`.
- [ ] High alerts match SQL count.
- [ ] Critical alerts match SQL count.
- [ ] Alerts by reason match SQL grouping.
- [ ] Alert table filters correctly.

### Merchant Risk Page

- [ ] Merchant count matches `bi.merchant_risk_summary`.
- [ ] Top merchants sort correctly.
- [ ] Scatter plot uses numeric X and Y fields.
- [ ] Merchant Risk Index appears and behaves correctly.
- [ ] Category slicer filters merchant visuals.

### User & Device Risk Page

- [ ] Top wallets sort by fraud score.
- [ ] Wallet detail table shows correct fields.
- [ ] Device count and receiver count are numeric.
- [ ] Wallet filters do not break visuals.

### Geospatial Page

- [ ] Governorate field is populated.
- [ ] Map visual displays locations.
- [ ] Hotspot ranking matches SQL.
- [ ] Governorate slicer filters visuals.

### Alert Investigation Page

- [ ] Alert queue loads.
- [ ] Alert status filters work.
- [ ] Alert priority sorting works.
- [ ] Date slicer filters alert trends.
- [ ] Tables show transaction-level detail.

---

## 🧪 Useful SQL Checks for Power BI Validation

### Validate Daily KPI Source

```sql
SELECT *
FROM bi.fact_daily_fraud_kpi
ORDER BY date_key
LIMIT 20;
```

---

### Validate Alert Queue

```sql
SELECT
    risk_band,
    alert_status,
    COUNT(*) AS alerts
FROM bi.alert_queue
GROUP BY risk_band, alert_status
ORDER BY risk_band, alert_status;
```

---

### Validate Date Range

```sql
SELECT
    MIN(date_key) AS min_date,
    MAX(date_key) AS max_date,
    COUNT(*) AS days
FROM bi.dim_date;
```

---

### Validate Risk Band Distribution

```sql
SELECT
    risk_band,
    transaction_count
FROM bi.risk_band_distribution
ORDER BY transaction_count DESC;
```

---

### Validate Merchant Risk Index

```sql
SELECT
    merchant_id,
    merchant_name,
    transaction_count,
    flagged_rate,
    avg_fraud_score,
    merchant_risk_index
FROM bi.merchant_risk_summary
ORDER BY merchant_risk_index DESC
LIMIT 20;
```

---

## 📸 Screenshot Naming Convention

Recommended screenshot names:

```text
page_1_executive_overview.png
page_2_fraud_ops_center.png
page_3_merchant_risk.png
page_4_user_device_risk.png
page_5_geospatial_analysis.png
page_6_alert_investigation.png
```

Use these screenshots in the main project README to make the repository visually strong.

---

## 🏆 Final Power BI Outcome

The Power BI layer successfully delivered:

- ✅ 6-page professional fraud dashboard
- ✅ Executive KPI reporting
- ✅ Fraud alert monitoring
- ✅ Merchant risk analysis
- ✅ User and device risk analysis
- ✅ Geographic hotspot analysis
- ✅ Alert investigation queue
- ✅ Validated DAX measures
- ✅ Clean relationships with date and risk-band dimensions
- ✅ Dark fintech fraud-ops dashboard theme

---

<div align="center">

## 🚀 Power BI Layer Summary

**This Power BI report turns PostgreSQL fraud scoring outputs into an interactive fraud monitoring and investigation dashboard.**

</div>
