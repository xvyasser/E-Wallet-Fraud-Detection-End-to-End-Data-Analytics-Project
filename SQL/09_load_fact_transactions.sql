
CREATE OR REPLACE PROCEDURE dw.load_fact_transactions_for_month(
	p_start_date DATE,
	p_end_date DATE
)

LANGUAGE plpgsql
AS $$

BEGIN

WITH valid_month AS(

SELECT *
FROM staging.clean_transactions_work
WHERE validation_status = 'Valid'
AND parsed_transaction_ts>= p_start_date AND parsed_transaction_ts<p_end_date

),

deduped AS(

SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY loaded_at DESC, staging_transaction_id DESC) as rn
FROM valid_month
)


INSERT INTO dw.fact_transaction (
        transaction_id,

        sender_user_sk,
        receiver_user_sk,
        merchant_sk,
        device_sk,

        sender_wallet_id,
        receiver_wallet_id,
        merchant_id,
        device_id,

        transaction_type,
        transaction_status,

        transaction_amount,
        currency,

        transaction_ts,
        transaction_date,

        latitude,
        longitude,

        channel,

        is_fraud_injected,
        fraud_pattern
)

SELECT
	d.transaction_id,

	du1.user_sk AS sender_user_sk,
	du2.user_sk AS receiver_user_sk,

	dm.merchant_sk,
	
	dd.device_sk,

	d.sender_wallet_id,
	d.receiver_wallet_id,
	d.merchant_id,
	d.device_id,

	COALESCE(ttm.normalized_type,'Unknown') AS transaction_type,
	COALESCE(tsm.normalized_status,'Unknown') AS transaction_status,

    d.parsed_amount AS transaction_amount,
    d.normalized_currency AS currency,

    d.parsed_transaction_ts AS transaction_ts,
    d.parsed_transaction_ts::date AS transaction_date,

    d.parsed_latitude AS latitude,
    d.parsed_longitude AS longitude,

    d.channel,

    d.is_fraud_injected,
    d.fraud_pattern

FROM deduped d

LEFT JOIN dw.dim_user du1
ON d.sender_wallet_id = du1.wallet_id
AND du1.is_current = TRUE

LEFT JOIN dw.dim_user du2
ON d.receiver_wallet_id = du2.wallet_id
AND du2.is_current = TRUE

LEFT JOIN dw.dim_merchant dm
ON d.merchant_id = dm.merchant_id
AND dm.is_current = TRUE

LEFT JOIN dw.dim_device dd
ON d.device_id = dd.device_id

LEFT JOIN ref.transaction_type_map ttm
ON d.raw_transaction_type = ttm.raw_type

LEFT JOIN ref.transaction_status_map tsm
ON d.raw_transaction_status = tsm.raw_status

WHERE rn =1;

END;
$$;

CALL dw.load_fact_transactions_for_month('2025-01-01', '2025-02-01');
CALL dw.load_fact_transactions_for_month('2025-02-01', '2025-03-01');
CALL dw.load_fact_transactions_for_month('2025-03-01', '2025-04-01');
CALL dw.load_fact_transactions_for_month('2025-04-01', '2025-05-01');
CALL dw.load_fact_transactions_for_month('2025-05-01', '2025-06-01');
CALL dw.load_fact_transactions_for_month('2025-06-01', '2025-07-01');
CALL dw.load_fact_transactions_for_month('2025-07-01', '2025-08-01');
CALL dw.load_fact_transactions_for_month('2025-08-01', '2025-09-01');
CALL dw.load_fact_transactions_for_month('2025-09-01', '2025-10-01');
CALL dw.load_fact_transactions_for_month('2025-10-01', '2025-11-01');
CALL dw.load_fact_transactions_for_month('2025-11-01', '2025-12-01');
CALL dw.load_fact_transactions_for_month('2025-12-01', '2026-01-01');

ANALYZE dw.fact_transaction;
ANALYZE audit.rejected_transactions;