DROP TABLE IF EXISTS staging.clean_transactions_work;

CREATE UNLOGGED TABLE staging.clean_transactions_work AS

WITH parsed AS(

SELECT
	staging_transaction_id,
	NULLIF(TRIM(raw_transaction_id),'') AS raw_transaction_id,
	NULLIF(TRIM(transaction_id),'') AS transaction_id,
	NULLIF(TRIM(sender_wallet_id), '') AS sender_wallet_id,
    NULLIF(TRIM(receiver_wallet_id), '') AS receiver_wallet_id,
    NULLIF(TRIM(merchant_id), '') AS merchant_id,

    NULLIF(TRIM(transaction_type), '') AS raw_transaction_type,
    NULLIF(TRIM(transaction_status), '') AS raw_transaction_status,

 	transaction_amount AS raw_transaction_amount,

	CASE
		WHEN transaction_amount ~ '^-?\d+(\.\d+)?$'
		THEN transaction_amount::numeric(18,2)
	ELSE NULL
	END AS parsed_amount,

    CASE
        WHEN UPPER(TRIM(currency)) = 'EGP' THEN 'EGP'
    ELSE 'Unknown'
    END AS normalized_currency,

	CASE
        WHEN transaction_ts ~ '^\d{4}-\d{2}-\d{2}'
        THEN transaction_ts::timestamp
        WHEN transaction_ts ~ '^\d{2}/\d{2}/\d{4}'
        THEN TO_TIMESTAMP(transaction_ts, 'DD/MM/YYYY HH24:MI')
        WHEN transaction_ts ~ '^\d{2}-\d{2}-\d{4}'
        THEN TO_TIMESTAMP(transaction_ts, 'MM-DD-YYYY HH24:MI')
    ELSE NULL
    END AS parsed_transaction_ts,

	latitude AS raw_latitude,

	CASE
   		 WHEN latitude ~ '^-?\d+(\.\d+)?$'
         AND latitude::numeric BETWEEN 22 AND 32
        THEN latitude::numeric(9,6)
    ELSE NULL
	END AS parsed_latitude,

	longitude AS raw_longitude,

	CASE
  		  WHEN longitude ~ '^-?\d+(\.\d+)?$'
     	    AND longitude::numeric BETWEEN 24 AND 37
        THEN longitude::numeric(9,6)
    ELSE NULL
	END AS parsed_longitude,

        NULLIF(TRIM(device_id), '') AS device_id,
        NULLIF(TRIM(channel), '') AS channel,

        CASE
            WHEN LOWER(TRIM(is_fraud_injected)) = 'true' THEN TRUE
            ELSE FALSE
        END AS is_fraud_injected,

        COALESCE(NULLIF(TRIM(fraud_pattern), ''), 'normal') AS fraud_pattern,

        source_file,
        loaded_at

  FROM staging.raw_transactions
),

Validated AS(

SELECT
	*,
	CASE
		WHEN transaction_id IS NULL THEN 'Rejected'
		WHEN sender_wallet_id IS NULL THEN 'Rejected'
		WHEN parsed_transaction_ts IS NULL THEN 'Rejected'
		WHEN parsed_amount <= 0 THEN 'Rejected'
        WHEN parsed_transaction_ts < '2025-01-01'::timestamp THEN 'Rejected'
        WHEN parsed_transaction_ts >= '2026-01-01'::timestamp THEN 'Rejected'
		ELSE 'Valid'
    END AS validation_status,

    CASE
        WHEN transaction_id IS NULL THEN 'Missing transaction_id'
        WHEN sender_wallet_id IS NULL THEN 'Missing sender_wallet_id'
        WHEN parsed_transaction_ts IS NULL THEN 'Invalid transaction timestamp'
        WHEN parsed_amount IS NULL THEN 'Invalid transaction amount'
        WHEN parsed_amount <= 0 THEN 'Amount less than or equal to zero'
        WHEN parsed_transaction_ts < '2025-01-01'::timestamp THEN 'Transaction date before 2025'
        WHEN parsed_transaction_ts >= '2026-01-01'::timestamp THEN 'Transaction date after 2025'
        ELSE NULL
    END AS rejection_reason

    FROM parsed
)

SELECT *
FROM validated;


CREATE INDEX idx_clean_txn_status
ON staging.clean_transactions_work(validation_status);

CREATE INDEX idx_clean_txn_transaction_id
ON staging.clean_transactions_work(transaction_id);

CREATE INDEX idx_clean_txn_ts
ON staging.clean_transactions_work(parsed_transaction_ts);

CREATE INDEX idx_clean_txn_sender_wallet
ON staging.clean_transactions_work(sender_wallet_id);

CREATE INDEX idx_clean_txn_receiver_wallet
ON staging.clean_transactions_work(receiver_wallet_id);

CREATE INDEX idx_clean_txn_merchant
ON staging.clean_transactions_work(merchant_id);

CREATE INDEX idx_clean_txn_device
ON staging.clean_transactions_work(device_id);

ANALYZE staging.clean_transactions_work;


