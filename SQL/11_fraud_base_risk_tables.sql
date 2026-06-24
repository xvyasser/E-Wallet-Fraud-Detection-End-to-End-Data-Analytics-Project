--------------------------------------------------------
--Creating Fraud Base Risk Tables :
--------------------------------------------------------

--Creating Device Risk Base Table :


DROP TABLE IF EXISTS fraud.device_risk_base CASCADE;

CREATE TABLE fraud.device_risk_base AS 
SELECT
	device_id,
	count(*) AS transaction_count,
	COUNT(DISTINCT sender_wallet_id) AS wallets_per_device,
	COUNT(*) FILTER(WHERE transaction_status ='Success') AS success_transaction_count,
	COUNT(*) FILTER(WHERE transaction_status ='Failed') AS failed_transaction_count,
	ROUND(
			COUNT(*) FILTER(WHERE transaction_status ='Failed')::numeric/NULLIF(COUNT(*),0),4
	) AS device_failed_rate
FROM dw.fact_transaction
WHERE device_id IS NOT NULL
GROUP BY device_id;

CREATE INDEX idx_device_risk_base_device
ON fraud.device_risk_base(device_id);

ANALYZE fraud.device_risk_base;


--Creating Merchant Risk Base Table :


DROP TABLE IF EXISTS fraud.merchant_risk_base CASCADE;

CREATE TABLE fraud.merchant_risk_base AS
SELECT
    merchant_id,
	COUNT(*) AS transaction_count,
	SUM(transaction_amount) AS total_amount,
	AVG(transaction_amount) AS avg_amount,
	COUNT(DISTINCT sender_wallet_id) AS unique_customer_count,
	COUNT(*) FILTER(WHERE transaction_status = 'Failed') AS failed_transaction_count,
	ROUND(
			COUNT(*) FILTER(WHERE transaction_status ='Failed')::numeric/NULLIF(COUNT(*),0),4
	) AS merchant_failed_rate,
	ROUND(
        COUNT(*) FILTER (
            WHERE is_fraud_injected = TRUE
        )::numeric
        / NULLIF(COUNT(*), 0),
        4
    ) AS injected_fraud_rate
FROM dw.fact_transaction
WHERE merchant_id IS NOT NULL
GROUP BY merchant_id;

CREATE INDEX idx_merchant_risk_base_merchant
ON fraud.merchant_risk_base(merchant_id);

ANALYZE fraud.merchant_risk_base;


--Creating Sender Hourly Reciever Counts Table :

DROP TABLE IF EXISTS fraud.sender_hourly_receiver_counts CASCADE;

CREATE UNLOGGED TABLE fraud.sender_hourly_receiver_counts AS

SELECT
	sender_wallet_id,
	DATE_TRUNC('hour',transaction_ts) AS hour_bucket,
	COUNT(*) AS transactions_count_1hr,
	COUNT(DISTINCT receiver_wallet_id) AS unique_receivers_1h,
	SUM(transaction_amount) AS total_amount

FROM dw.fact_transaction
WHERE sender_wallet_id IS NOT NULL
GROUP BY
    sender_wallet_id,
    DATE_TRUNC('hour', transaction_ts);

CREATE INDEX idx_sender_hourly_receiver_sender_hour
ON fraud.sender_hourly_receiver_counts(sender_wallet_id, hour_bucket);

ANALYZE fraud.sender_hourly_receiver_counts;