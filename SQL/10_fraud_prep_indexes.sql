CREATE INDEX IF NOT EXISTS idx_fact_sender_ts
ON dw.fact_transaction(sender_wallet_id,transaction_ts);

CREATE INDEX IF NOT EXISTS idx_fact_merchant_ts
ON dw.fact_transaction(merchant_id,transaction_ts);

CREATE INDEX IF NOT EXISTS idx_fact_device_ts
ON dw.fact_transaction(device_id,transaction_ts);

CREATE INDEX IF NOT EXISTS idx_fact_status_ts
ON dw.fact_transaction(transaction_status,transaction_ts);

CREATE INDEX IF NOT EXISTS idx_fact_fraud_pattern
ON dw.fact_transaction(fraud_pattern);

ANALYZE dw.fact_transaction;