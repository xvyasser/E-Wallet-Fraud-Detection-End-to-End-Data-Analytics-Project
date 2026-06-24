-- Helpful indexes after CSV loading.
-- These make cleaning, deduplication, and joins faster.

--Indexes for the raw_transactions table:

CREATE INDEX IF NOT EXISTS idx_raw_transactions_transaction_id
ON staging.raw_transactions(transaction_id);

CREATE INDEX IF NOT EXISTS idx_raw_transactions_sender_wallet_id
ON staging.raw_transactions(sender_wallet_id);

CREATE INDEX IF NOT EXISTS idx_raw_transactions_receiver_wallet_id
ON staging.raw_transactions(receiver_wallet_id);

CREATE INDEX IF NOT EXISTS idx_raw_transactions_merchant_id
ON staging.raw_transactions(merchant_id);

CREATE INDEX IF NOT EXISTS idx_raw_transactions_device_id
ON staging.raw_transactions(device_id);

CREATE INDEX IF NOT EXISTS idx_raw_transactions_source_file
ON staging.raw_transactions(source_file);

--Indexes for the raw_users table:

CREATE INDEX IF NOT EXISTS idx_raw_users_raw_user_id
ON staging.raw_users(raw_user_id);

CREATE INDEX IF NOT EXISTS idx_raw_users_wallet_id
ON staging.raw_users(wallet_id);

--Indexes for the raw_merchants table:

CREATE INDEX IF NOT EXISTS idx_raw_merchants_merchant_id
ON staging.raw_merchants(merchant_id);

CREATE INDEX IF NOT EXISTS idx_raw_merchants_raw_merchant_id
ON staging.raw_merchants(raw_merchant_id);


ANALYZE staging.raw_users;
ANALYZE staging.raw_merchants;
ANALYZE staging.raw_transactions;