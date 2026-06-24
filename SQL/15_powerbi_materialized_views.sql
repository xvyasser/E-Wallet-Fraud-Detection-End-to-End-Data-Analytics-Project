-------------------------------------------------------------------
-- 1- Daily Fraud Summary :
-------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS fraud.mv_daily_fraud_summary;

CREATE MATERIALIZED VIEW  fraud.mv_daily_fraud_summary AS

SELECT
	t.transaction_date,
	
	COUNT(*) AS transaction_count,

	SUM(t.transaction_amount) AS total_amount,

	COUNT(*) FILTER(WHERE s.risk_band ='Low') AS low_risk_count,

	COUNT(*) FILTER(WHERE s.risk_band ='Medium') As medium_risk_count,

	COUNT(*) FILTER(WHERE s.risk_band ='High') AS high_risk_count,

	COUNT(*) FILTER(WHERE s.risk_band ='Critical') AS critical_risk_count,

	COUNT(*) FILTER(WHERE s.risk_band IN ('High','Critical')) AS flagged_transaction_count,

	SUM(t.transaction_amount) FILTER(WHERE s.risk_band IN ('High','Critical')) AS flagged_amount,

	ROUND(COUNT(*) FILTER(WHERE s.risk_band IN('High','Critical'))::numeric/NULLIF(COUNT(*),0),4) AS flagged_rate

FROM fraud.transaction_fraud_scores s
	
INNER JOIN dw.fact_transaction t
    ON s.transaction_id = t.transaction_id

GROUP BY t.transaction_date;

CREATE INDEX idx_mv_daily_fraud_summary_date
ON fraud.mv_daily_fraud_summary(transaction_date);

-------------------------------------------------------------------
-- 2- Merchant risk summary :
-------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS fraud.mv_merchant_risk_summary;

CREATE MATERIALIZED VIEW fraud.mv_merchant_risk_summary AS

SELECT
	t.merchant_id,
    m.merchant_name,
    m.normalized_category,
    m.category_group,
    m.governorate,
    m.city,

	COUNT(*) AS transaction_count,

	SUM(t.transaction_amount) AS total_amount,

    AVG(s.fraud_score) AS avg_fraud_score,

    MAX(s.fraud_score) AS max_fraud_score,

    COUNT(*) FILTER (WHERE s.risk_band IN ('High', 'Critical')) AS flagged_transaction_count,

	MAX(mr.merchant_failed_rate) AS merchant_failed_rate,

	ROUND(
    COUNT(*) FILTER (WHERE s.risk_band IN ('High', 'Critical'))::numeric/ NULLIF(COUNT(*), 0),4) AS flagged_rate

FROM fraud.transaction_fraud_scores s
JOIN dw.fact_transaction t
    ON s.transaction_id = t.transaction_id

LEFT JOIN dw.dim_merchant m
    ON t.merchant_sk = m.merchant_sk

LEFT JOIN fraud.merchant_risk_base mr
    ON t.merchant_id = mr.merchant_id

WHERE t.merchant_id IS NOT NULL

GROUP BY
    t.merchant_id,
    m.merchant_name,
    m.normalized_category,
    m.category_group,
    m.governorate,
    m.city;

CREATE INDEX idx_mv_merchant_risk_summary_merchant
ON fraud.mv_merchant_risk_summary(merchant_id);

CREATE INDEX idx_mv_merchant_risk_summary_category
ON fraud.mv_merchant_risk_summary(normalized_category);


-------------------------------------------------------------------
-- 3- User risk summary :
-------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS fraud.mv_user_risk_summary;

CREATE MATERIALIZED VIEW fraud.mv_user_risk_summary AS
SELECT
    t.sender_wallet_id,

    u.governorate,
    u.city,
    u.kyc_status,
    u.account_status,

    COUNT(*) AS transaction_count,

    SUM(t.transaction_amount) AS total_amount,

    AVG(s.fraud_score) AS avg_fraud_score,

    MAX(s.fraud_score) AS max_fraud_score,

    COUNT(*) FILTER (WHERE s.risk_band IN ('High', 'Critical')) AS flagged_transaction_count,

    ROUND(
        COUNT(*) FILTER (WHERE s.risk_band IN ('High', 'Critical'))::numeric/ NULLIF(COUNT(*), 0),4) AS flagged_rate,

    COUNT(DISTINCT t.device_id) AS distinct_device_count,

    COUNT(DISTINCT t.receiver_wallet_id) AS distinct_receiver_count,

    COUNT(DISTINCT t.merchant_id) AS distinct_merchant_count

FROM fraud.transaction_fraud_scores s
JOIN dw.fact_transaction t
    ON s.transaction_id = t.transaction_id

LEFT JOIN dw.dim_user u
    ON t.sender_user_sk = u.user_sk

GROUP BY
    t.sender_wallet_id,
    u.governorate,
    u.city,
    u.kyc_status,
    u.account_status;

CREATE INDEX idx_mv_user_risk_summary_wallet
ON fraud.mv_user_risk_summary(sender_wallet_id);

CREATE INDEX idx_mv_user_risk_summary_flagged_rate
ON fraud.mv_user_risk_summary(flagged_rate);


-------------------------------------------------------------------
-- 4- High risk transactions :
-------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS fraud.mv_high_risk_transactions;

CREATE MATERIALIZED VIEW fraud.mv_high_risk_transactions AS
SELECT
    s.transaction_id,
    s.sender_wallet_id,
    s.merchant_id,
    s.device_id,
    s.transaction_ts,

    t.transaction_amount,
    t.transaction_type,
    t.transaction_status,
    t.latitude,
    t.longitude,
    t.channel,

    s.velocity_score,
    s.geo_score,
    s.device_score,
    s.merchant_score,
    s.amount_score,
    s.fraud_score,
    s.risk_band,
    s.main_reason,

    s.is_fraud_injected,
    s.fraud_pattern

FROM fraud.transaction_fraud_scores s
JOIN dw.fact_transaction t
    ON s.transaction_id = t.transaction_id

WHERE s.risk_band IN ('High', 'Critical');

CREATE INDEX idx_mv_high_risk_transactions_ts
ON fraud.mv_high_risk_transactions(transaction_ts);

CREATE INDEX idx_mv_high_risk_transactions_risk
ON fraud.mv_high_risk_transactions(risk_band);

CREATE INDEX idx_mv_high_risk_transactions_wallet
ON fraud.mv_high_risk_transactions(sender_wallet_id);


REFRESH MATERIALIZED VIEW fraud.mv_daily_fraud_summary;
REFRESH MATERIALIZED VIEW fraud.mv_merchant_risk_summary;
REFRESH MATERIALIZED VIEW fraud.mv_user_risk_summary;
REFRESH MATERIALIZED VIEW fraud.mv_high_risk_transactions;