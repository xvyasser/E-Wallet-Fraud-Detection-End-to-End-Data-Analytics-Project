# 📊 E-Wallet Fraud Detection Dashboard — Power BI Service & Screenshots

<div align="center">

## 💳 Interactive Fraud Monitoring Dashboard  
### Power BI Service • Executive KPIs • Fraud Alerts • Merchant Risk • Wallet Risk • Geographic Hotspots

**This document contains the Power BI Service access link and screenshot showcase for the E-Wallet Fraud Detection Dashboard.**

![Power BI](https://img.shields.io/badge/Power%20BI-Service%20Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Fraud Analytics](https://img.shields.io/badge/Fraud%20Analytics-E--Wallet%20Monitoring-DC2626?style=for-the-badge)
![Dashboard](https://img.shields.io/badge/Dashboard-6%20Pages-22C55E?style=for-the-badge)
![PostgreSQL](https://img.shields.io/badge/Data%20Source-PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)

</div>

---

# 🔗 Power BI Service Link

> Replace the placeholder below with your actual Power BI Service published report link.

## 🚀 Open the Interactive Dashboard

[👉 View the Power BI Dashboard](https://app.powerbi.com/view?r=eyJrIjoiYTA2NzAyNGUtNmEzZC00Mjk2LTkzMTMtZjE1ZjhiMzUwMTdmIiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9&pageName=f2c0d7c930d58c3ab998)

---

# 📌 Dashboard Overview

The **E-Wallet Fraud Detection Dashboard** is a 6-page Power BI report built to monitor suspicious digital wallet transactions, identify risky merchants and wallets, detect fraud patterns, and support alert investigation.

The dashboard connects to curated PostgreSQL BI views created from the fraud scoring pipeline.

Main fraud monitoring areas:

- 👔 Executive fraud overview
- 🚨 Fraud alert monitoring
- 🌍 Geographic fraud hotspots
- 👤 Customer / wallet risk
- 🏪 Merchant risk analysis
- 🧾 Alert investigation queue

---

# 🧭 Dashboard Pages

| Page | Name | Main Purpose |
|---:|---|---|
| 1 | Executive Fraud Overview | High-level fraud exposure and KPIs |
| 2 | Fraud Ops Center | Alert monitoring and fraud reason analysis |
| 3 | Merchant Risk Analysis | Risky merchants and merchant-category behavior |
| 4 | User & Device Risk | Suspicious wallets, receivers, and device-sharing patterns |
| 5 | Geospatial Fraud Analysis | Fraud hotspots by governorate/location |
| 6 | Alert Investigation | Investigation queue and alert prioritization |

---

# 📸 Dashboard Screenshots


Recommended structure:

```text
screenshots/
├── page_1_executive_overview.png
├── page_2_fraud_ops_center.png
├── page_3_merchant_risk.png
├── page_4_user_device_risk.png
├── page_5_geospatial_analysis.png
└── page_6_alert_investigation.png
```

---

# 1️⃣ Executive Fraud Overview

## 🎯 Purpose

The Executive Fraud Overview page provides a high-level summary of the fraud situation across the e-wallet platform.

It is designed for managers and decision-makers who need quick answers without going into transaction-level detail.

## 📌 Main Questions Answered

- How many transactions were processed?
- What is the total transaction amount?
- How many transactions were flagged?
- What is the flagged transaction rate?
- How much money is associated with flagged transactions?
- How many transactions are Critical risk?
- How is fraud changing over time?

---

# 2️⃣ Fraud Ops Center

## 🎯 Purpose

The Fraud Ops Center page helps fraud analysts monitor generated alerts and understand the main reasons behind suspicious activity.

It is focused on alert volume, alert reasons, and high-priority transaction review.

## 📌 Main Questions Answered

- How many alerts were generated?
- How many alerts are open?
- How many alerts are High or Critical?
- What are the most common alert reasons?
- Which suspicious transactions should analysts review first?

---

# 3️⃣ Merchant Risk Analysis

## 🎯 Purpose

The Merchant Risk Analysis page identifies suspicious merchants and merchant categories.

It helps risk teams review merchants based on transaction volume, flagged activity, failed-rate behavior, and composite merchant risk.

## 📌 Main Questions Answered

- Which merchants are most risky?
- Which merchants combine high transaction volume with high risk?
- Which merchant categories show suspicious behavior?
- Which merchants should be reviewed first?

---

# 4️⃣ User & Device Risk

## 🎯 Purpose

The User & Device Risk page highlights suspicious wallets, customers, and shared-device behavior.

It supports investigation of wallets with high fraud scores, abnormal receiver behavior, and suspicious device usage.

## 📌 Main Questions Answered

- Which wallets have the highest fraud score?
- Which wallets interact with many receivers?
- Which wallets use many devices?
- Which devices may be connected to suspicious wallet rings?


---

# 5️⃣ Geospatial Fraud Analysis

## 🎯 Purpose

The Geospatial Fraud Analysis page shows where suspicious activity is concentrated geographically.

It helps fraud and risk teams identify governorates or regions with high flagged activity or Critical cases.

## 📌 Main Questions Answered

- Which governorates have the highest suspicious activity?
- Where are Critical cases concentrated?
- Are fraud patterns geographically clustered?
- Which areas should receive closer monitoring?


---

# 6️⃣ Alert Investigation

## 🎯 Purpose

The Alert Investigation page supports fraud operations and alert triage.

It provides an investigation queue where analysts can review suspicious transactions by fraud score, risk band, alert reason, wallet, merchant, and device.

## 📌 Main Questions Answered

- Which alerts are open?
- Which alerts are highest priority?
- What is the alert workload?
- Which transactions need immediate review?
- What fraud reason is attached to each alert?


---

# 🧠 Dashboard Features

## ✅ Executive KPIs

The dashboard includes key fraud monitoring KPIs such as:

- Total Transactions
- Total Amount
- Flagged Transactions
- Flagged Rate
- Flagged Amount
- Critical Transactions
- Total Alerts
- Open Alerts
- High Alerts
- Critical Alerts

---

## ✅ Fraud Pattern Monitoring

The dashboard tracks several fraud-related behaviors:

| Fraud Pattern | Meaning |
|---|---|
| 🌍 Impossible Travel | Same wallet appearing in distant locations too quickly |
| 🕸️ Smurfing Behavior | Wallet sending to many receivers in a short time |
| 📱 Shared Device Ring | Many wallets linked to the same device |
| 🏪 Merchant Abuse | Suspicious merchant failed-rate or risk behavior |
| ⚡ High Velocity Behavior | Too many transactions or high amount in a short window |
| 💸 Unusual Transaction Amount | Large transaction value requiring review |

---

## ✅ Risk Band Classification

Transactions are classified into four risk bands:

| Risk Band | Meaning |
|---|---|
| 🟢 Low | Normal or low-risk activity |
| 🟡 Medium | Suspicious behavior that may require monitoring |
| 🟠 High | Strong fraud signals requiring review |
| 🔴 Critical | Severe risk requiring immediate attention |

---

## ✅ Dashboard Interactivity

The report includes slicers and filters such as:

- Date
- Risk Band
- Alert Reason
- Alert Status
- Governorate
- Merchant Category

These slicers allow users to move from executive-level monitoring into more detailed investigation.

---

## 🚀 Final Dashboard Statement

**This dashboard transforms scored e-wallet transactions into interactive fraud intelligence for executives, analysts, and risk teams.**

</div>
