------------------------------------------------------------
--Createing a clean reporting layer for Power BI :
------------------------------------------------------------

--Creating a view for date :

CREATE SCHEMA IF NOT EXISTS bi;

CREATE OR REPLACE VIEW bi.dim_date AS

SELECT 
	date::date As date_key,

	EXTRACT(YEAR from date)::int AS year,

	EXTRACT(MONTH FROM date):: int AS month_number,

	TO_CHAR(date,'Month') AS month_name,

	TO_CHAR(date,'YYYY-MM') As year_month,

	EXTRACT(DOW FROM date)::int AS week_number,

	TO_CHAR(date,'Day') AS day_of_week_name

FROM GENERATE_SERIES(
						(SELECT MIN(transaction_date) FROM fraud.mv_daily_fraud_summary),
						(SELECT MAX(transaction_date) FROM fraud.mv_daily_fraud_summary),
						interval '1 day'
) AS date;



--Creating a view for risk band :

CREATE OR REPLACE VIEW bi.dim_risk_band AS

SELECT
    'Low' AS risk_band,
    1 AS risk_band_sort,
    'Monitor' AS review_priority

UNION ALL

SELECT
    'Medium' AS risk_band,
    2 AS risk_band_sort,
    'Watch' AS review_priority

UNION ALL

SELECT
    'High' AS risk_band,
    3 AS risk_band_sort,
    'Review' AS review_priority

UNION ALL

SELECT
    'Critical' AS risk_band,
    4 AS risk_band_sort,
    'Urgent Review' AS review_priority;


--Creating a view for fraud KPI :

CREATE OR REPLACE VIEW bi.fact_daily_fraud_kpi AS

SELECT
    transaction_date AS date_key,

    transaction_count,

    total_amount,

    low_risk_count,

    medium_risk_count,

    high_risk_count,

    critical_risk_count,

    flagged_transaction_count,

    flagged_amount,

    flagged_rate

FROM fraud.mv_daily_fraud_summary;


--Creating a view for  merchant risk :

CREATE OR REPLACE VIEW bi.merchant_risk_summary AS

SELECT
    merchant_id,

    merchant_name,

    normalized_category,

    category_group,

    governorate,

    city,

    transaction_count,

    total_amount,

    avg_fraud_score,

    max_fraud_score,

    flagged_transaction_count,

    flagged_rate,

    merchant_failed_rate

FROM fraud.mv_merchant_risk_summary;


--Creating a view for  user risk :

CREATE OR REPLACE VIEW bi.user_risk_summary AS

SELECT
    sender_wallet_id,

    governorate,

    city,

    kyc_status,

    account_status,

    transaction_count,

    total_amount,

    avg_fraud_score,

    max_fraud_score,

    flagged_transaction_count,

    flagged_rate,

    distinct_device_count,

    distinct_receiver_count,

    distinct_merchant_count

FROM fraud.mv_user_risk_summary;


--Creating a view for  high risk transactions :


CREATE OR REPLACE VIEW bi.high_risk_transactions AS

SELECT
    transaction_id,

    sender_wallet_id,

    merchant_id,

    device_id,

    transaction_ts,

    transaction_ts::date AS date_key,

    transaction_amount,

    transaction_type,

    transaction_status,

    latitude,

    longitude,

    channel,

    velocity_score,

    geo_score,

    device_score,

    merchant_score,

    amount_score,

    fraud_score,

    risk_band,

    main_reason,

    is_fraud_injected,

    fraud_pattern

FROM fraud.mv_high_risk_transactions;



--Creating a view for fraud alert :


CREATE OR REPLACE VIEW bi.alert_queue AS

SELECT
    alert_id,

    transaction_id,

    sender_wallet_id,

    merchant_id,

    device_id,

    fraud_score,

    risk_band,

    CASE
        WHEN risk_band = 'Critical' THEN 1
        WHEN risk_band = 'High' THEN 2
        ELSE 3
    END AS alert_priority_sort,

    alert_reason,

    alert_status,

    created_at,

    created_at::date AS created_date

FROM fraud.fraud_alerts;


