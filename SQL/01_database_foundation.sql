-------------------------------------------------------
--Creating Schemas :
-------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS staging; --For the raw messy data
CREATE SCHEMA IF NOT EXISTS ref;     --For unchanged reference tables
CREATE SCHEMA IF NOT EXISTS dw;      --For clean dimensional tables
CREATE SCHEMA IF NOT EXISTS fraud;   --For fraud features, scores, etc...
CREATE SCHEMA IF NOT EXISTS audit;   

-------------------------------------------------------
--Creating tables for raw data in the staging schema :
-------------------------------------------------------

/* Most columns' type in the raw tables are TEXT because the raw data are messy
   and the tranformations and cleaning parts are in the dw schema */

-- 1.1- Raw Users Table :

DROP TABLE IF EXISTS staging.raw_users;

CREATE TABLE staging.raw_users (
    staging_user_id BIGSERIAL PRIMARY KEY,

    raw_user_id TEXT,
    wallet_id TEXT,
    full_name TEXT,
    phone_number TEXT,
    national_id_last4 TEXT,
    gender TEXT,
    date_of_birth TEXT,

    governorate TEXT,
    city TEXT,

    signup_ts TEXT,
    kyc_status TEXT,
    account_status TEXT,

    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT NOW()
);

-- 1.2- Raw Merchants Table :

DROP TABLE IF EXISTS staging.raw_merchants;

CREATE TABLE staging.raw_merchants (
    staging_merchant_id BIGSERIAL PRIMARY KEY,

    raw_merchant_id TEXT,
    merchant_id TEXT,
    merchant_name TEXT,
    merchant_category TEXT,

    governorate TEXT,
    city TEXT,
    latitude TEXT,
    longitude TEXT,

    onboarding_ts TEXT,
    merchant_status TEXT,

    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT NOW()
);

-- 1.3- Raw Transactions Table :

DROP TABLE IF EXISTS staging.raw_transactions;

CREATE TABLE staging.raw_transactions (
    staging_transaction_id BIGSERIAL PRIMARY KEY,

    raw_transaction_id TEXT,
    transaction_id TEXT,

    sender_wallet_id TEXT,
    receiver_wallet_id TEXT,
    merchant_id TEXT,

    transaction_type TEXT,
    transaction_status TEXT,
    transaction_amount TEXT,
    currency TEXT,

    transaction_ts TEXT,

    latitude TEXT,
    longitude TEXT,
    device_id TEXT,
    channel TEXT,

    is_fraud_injected TEXT,
    fraud_pattern TEXT,

    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT NOW()
);


-------------------------------------------------------
--Creating Reference Tables in the ref schema :
-------------------------------------------------------

-- 2.1- Governorates Table :

DROP TABLE IF EXISTS ref.governorates;

CREATE TABLE ref.governorates (
    governorate_id SERIAL PRIMARY KEY,
    governorate_name_en TEXT NOT NULL UNIQUE,
    governorate_name_ar TEXT,
    region TEXT,
    center_latitude NUMERIC(9,6),
    center_longitude NUMERIC(9,6)
);

--Inserting data into the governorates table :

INSERT INTO ref.governorates 
(governorate_name_en, governorate_name_ar, region, center_latitude, center_longitude)
VALUES
('Cairo', 'القاهرة', 'Greater Cairo', 30.044400, 31.235700),
('Giza', 'الجيزة', 'Greater Cairo', 30.013100, 31.208900),
('Alexandria', 'الإسكندرية', 'North Coast', 31.200100, 29.918700),
('Dakahlia', 'الدقهلية', 'Delta', 31.040900, 31.378500),
('Red Sea', 'البحر الأحمر', 'Upper Egypt / Red Sea', 27.257900, 33.811600),
('Beheira', 'البحيرة', 'Delta', 30.848100, 30.343600),
('Fayoum', 'الفيوم', 'Upper Egypt', 29.308400, 30.842800),
('Gharbia', 'الغربية', 'Delta', 30.875400, 31.033500),
('Ismailia', 'الإسماعيلية', 'Suez Canal', 30.596500, 32.271500),
('Menofia', 'المنوفية', 'Delta', 30.597200, 30.987600),
('Minya', 'المنيا', 'Upper Egypt', 28.109900, 30.750300),
('Qaliubiya', 'القليوبية', 'Greater Cairo', 30.329200, 31.216800),
('New Valley', 'الوادي الجديد', 'Upper Egypt', 25.447800, 30.546500),
('Suez', 'السويس', 'Suez Canal', 29.966800, 32.549800),
('Aswan', 'أسوان', 'Upper Egypt', 24.088900, 32.899800),
('Assiut', 'أسيوط', 'Upper Egypt', 27.180100, 31.189300),
('Beni Suef', 'بني سويف', 'Upper Egypt', 29.066100, 31.099400),
('Port Said', 'بورسعيد', 'Suez Canal', 31.265300, 32.301900),
('Damietta', 'دمياط', 'Delta', 31.416500, 31.813300),
('Sharkia', 'الشرقية', 'Delta', 30.732700, 31.719500),
('South Sinai', 'جنوب سيناء', 'Sinai', 28.233600, 33.614000),
('Kafr El Sheikh', 'كفر الشيخ', 'Delta', 31.111700, 30.939900),
('Matrouh', 'مطروح', 'North Coast', 31.354300, 27.237300),
('Luxor', 'الأقصر', 'Upper Egypt', 25.687200, 32.639600),
('Qena', 'قنا', 'Upper Egypt', 26.155100, 32.716000),
('North Sinai', 'شمال سيناء', 'Sinai', 31.124900, 33.800600),
('Sohag', 'سوهاج', 'Upper Egypt', 26.559100, 31.695700);


-- 2.2- Merchant Category Mapping Table :

DROP TABLE IF EXISTS ref.merchant_category_map;

CREATE TABLE ref.merchant_category_map (
    raw_category TEXT PRIMARY KEY,
    normalized_category TEXT NOT NULL,
    category_group TEXT
);

--Inserting data into the Merchant Category Mapping Table :

INSERT INTO ref.merchant_category_map
(raw_category, normalized_category, category_group)
VALUES
('food', 'Food & Beverage', 'Daily Spend'),
('Food', 'Food & Beverage', 'Daily Spend'),
('FOOD', 'Food & Beverage', 'Daily Spend'),
('restaurant', 'Food & Beverage', 'Daily Spend'),
('restaurants', 'Food & Beverage', 'Daily Spend'),
('F&B', 'Food & Beverage', 'Daily Spend'),

('grocery', 'Groceries', 'Daily Spend'),
('Groceries', 'Groceries', 'Daily Spend'),
('supermarket', 'Groceries', 'Daily Spend'),

('mobile topup', 'Mobile Recharge', 'Telecom'),
('topup', 'Mobile Recharge', 'Telecom'),
('airtime', 'Mobile Recharge', 'Telecom'),

('bills', 'Bill Payment', 'Utilities'),
('electricity', 'Bill Payment', 'Utilities'),
('water', 'Bill Payment', 'Utilities'),
('gas', 'Bill Payment', 'Utilities'),

('electronics', 'Electronics', 'Retail'),
('Electronics', 'Electronics', 'Retail'),
('mobile shop', 'Electronics', 'Retail'),

('fashion', 'Fashion', 'Retail'),
('clothes', 'Fashion', 'Retail'),
('apparel', 'Fashion', 'Retail'),

('transport', 'Transport', 'Mobility'),
('ride hailing', 'Transport', 'Mobility'),
('bus', 'Transport', 'Mobility'),

('education', 'Education', 'Services'),
('courses', 'Education', 'Services'),

('healthcare', 'Healthcare', 'Services'),
('pharmacy', 'Healthcare', 'Services'),

('unknown', 'Unknown', 'Unknown');


-- 2.3- Transaction Status Mapping Table :

DROP TABLE IF EXISTS ref.transaction_status_map;

CREATE TABLE ref.transaction_status_map (
    raw_status TEXT PRIMARY KEY,
    normalized_status TEXT NOT NULL
);

--Inserting data into the Status Mapping Table :

INSERT INTO ref.transaction_status_map
(raw_status, normalized_status)
VALUES
('SUCCESS', 'Success'),
('success', 'Success'),
('succeeded', 'Success'),
('done', 'Success'),
('Completed', 'Success'),

('FAILED', 'Failed'),
('failed', 'Failed'),
('fail', 'Failed'),
('declined', 'Failed'),
('rejected', 'Failed'),

('PENDING', 'Pending'),
('pending', 'Pending'),

('REVERSED', 'Reversed'),
('reversed', 'Reversed'),
('refund', 'Reversed');

-- 2.4- Transaction Type Mapping Table :

DROP TABLE IF EXISTS ref.transaction_type_map;

CREATE TABLE ref.transaction_type_map (
    raw_type TEXT PRIMARY KEY,
    normalized_type TEXT NOT NULL
);

--Inserting data into the Transaction Type Mapping Table :

INSERT INTO ref.transaction_type_map
(raw_type, normalized_type)
VALUES
('P2P', 'Wallet Transfer'),
('wallet_transfer', 'Wallet Transfer'),
('transfer', 'Wallet Transfer'),

('CASH_IN', 'Cash In'),
('cashin', 'Cash In'),
('deposit', 'Cash In'),

('CASH_OUT', 'Cash Out'),
('cashout', 'Cash Out'),
('withdrawal', 'Cash Out'),

('MERCHANT_PAYMENT', 'Merchant Payment'),
('merchant', 'Merchant Payment'),
('payment', 'Merchant Payment'),

('BILL_PAYMENT', 'Bill Payment'),
('bill', 'Bill Payment'),
('utility', 'Bill Payment'),

('TOPUP', 'Mobile Recharge'),
('airtime', 'Mobile Recharge'),
('mobile_topup', 'Mobile Recharge');


-------------------------------------------------------
--Creating cleand, ready-for-analysis Tables in the dw schema :
-------------------------------------------------------

-- 3.1- User Dimension Table :

DROP TABLE IF EXISTS dw.dim_user CASCADE;

CREATE TABLE dw.dim_user (
    user_sk BIGSERIAL PRIMARY KEY,

    wallet_id TEXT NOT NULL,
    full_name TEXT,
    phone_number TEXT,
    national_id_last4 TEXT,
    gender TEXT,
    date_of_birth DATE,

    governorate TEXT,
    city TEXT,

    signup_ts TIMESTAMP,
    kyc_status TEXT,
    account_status TEXT,

    valid_from TIMESTAMP NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    source_hash TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_dim_user_wallet_id 
ON dw.dim_user(wallet_id);

CREATE UNIQUE INDEX ux_dim_user_current_wallet
ON dw.dim_user(wallet_id)
WHERE is_current = TRUE;

-- 3.2- Merchant Dimension Table :

DROP TABLE IF EXISTS dw.dim_merchant CASCADE;

CREATE TABLE dw.dim_merchant (
    merchant_sk BIGSERIAL PRIMARY KEY,

    merchant_id TEXT NOT NULL,
    merchant_name TEXT,
    raw_category TEXT,
    normalized_category TEXT,
    category_group TEXT,

    governorate TEXT,
    city TEXT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),

    merchant_status TEXT,
    onboarding_ts TIMESTAMP,

    valid_from TIMESTAMP NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    source_hash TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_dim_merchant_merchant_id 
ON dw.dim_merchant(merchant_id);

CREATE INDEX idx_dim_merchant_category 
ON dw.dim_merchant(normalized_category);

CREATE UNIQUE INDEX ux_dim_merchant_current
ON dw.dim_merchant(merchant_id)
WHERE is_current = TRUE;

-- 3.4- Device Dimension Table :

DROP TABLE IF EXISTS dw.dim_device CASCADE;

CREATE TABLE dw.dim_device (
    device_sk BIGSERIAL PRIMARY KEY,

    device_id TEXT NOT NULL,
    device_type TEXT,
    os_name TEXT,

    first_seen_ts TIMESTAMP,
    last_seen_ts TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX ux_dim_device_device_id
ON dw.dim_device(device_id);

-- 3.5- Date Dimension Table :

DROP TABLE IF EXISTS dw.dim_date CASCADE;

CREATE TABLE dw.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name TEXT,
    day_of_month INTEGER,
    day_name TEXT,
    week_of_year INTEGER,
    is_weekend BOOLEAN
);


-- 3.6- Fact Partitioned Transaction Table :

DROP TABLE IF EXISTS dw.fact_transaction CASCADE;

CREATE TABLE dw.fact_transaction (
    transaction_sk BIGSERIAL,

    transaction_id TEXT NOT NULL,

    sender_user_sk BIGINT,
    receiver_user_sk BIGINT,
    merchant_sk BIGINT,
    device_sk BIGINT,

    sender_wallet_id TEXT,
    receiver_wallet_id TEXT,
    merchant_id TEXT,
    device_id TEXT,

    transaction_type TEXT,
    transaction_status TEXT,

    transaction_amount NUMERIC(18,2),
    currency TEXT,

    transaction_ts TIMESTAMP NOT NULL,
    transaction_date DATE NOT NULL,

    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),

    channel TEXT,

    is_fraud_injected BOOLEAN,
    fraud_pattern TEXT,

    created_at TIMESTAMP DEFAULT NOW()
)
PARTITION BY RANGE (transaction_ts);


-- 3.7- Creating partitioned tables by month :

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_01
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_02
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_03
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_04
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_05
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_06
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_07
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_08
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_09
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_10
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_11
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE IF NOT EXISTS dw.fact_transaction_2025_12
PARTITION OF dw.fact_transaction
FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- 3.8- Creating a default partition table for out of range dates :

CREATE TABLE IF NOT EXISTS dw.fact_transaction_default
PARTITION OF dw.fact_transaction
DEFAULT;

CREATE INDEX idx_fact_transaction_ts
ON dw.fact_transaction(transaction_ts);

CREATE INDEX idx_fact_transaction_sender_wallet
ON dw.fact_transaction(sender_wallet_id);

CREATE INDEX idx_fact_transaction_receiver_wallet
ON dw.fact_transaction(receiver_wallet_id);

CREATE INDEX idx_fact_transaction_merchant
ON dw.fact_transaction(merchant_id);

CREATE INDEX idx_fact_transaction_device
ON dw.fact_transaction(device_id);

CREATE INDEX idx_fact_transaction_status
ON dw.fact_transaction(transaction_status);

CREATE INDEX idx_fact_transaction_type
ON dw.fact_transaction(transaction_type);


-------------------------------------------------------
--Creating fraud table in the fraud schema :
-------------------------------------------------------

-- 4.1- Transaction Features Table :

DROP TABLE IF EXISTS fraud.transaction_features;

CREATE TABLE fraud.transaction_features (
    transaction_id TEXT PRIMARY KEY,

    sender_wallet_id TEXT,
    merchant_id TEXT,
    device_id TEXT,
    transaction_ts TIMESTAMP,

    txn_count_15m INTEGER,
    txn_count_1h INTEGER,
    amount_sum_1h NUMERIC(18,2),
    unique_receivers_1h INTEGER,

    distance_from_previous_txn_km NUMERIC(12,2),
    minutes_since_previous_txn NUMERIC(12,2),

    wallets_per_device INTEGER,
    merchant_failed_rate NUMERIC(8,4),

    created_at TIMESTAMP DEFAULT NOW()
);

-- 4.2- Transaction Fraud Scores Table :

DROP TABLE IF EXISTS fraud.transaction_fraud_scores;

CREATE TABLE fraud.transaction_fraud_scores (
    transaction_id TEXT PRIMARY KEY,

    sender_wallet_id TEXT,
    merchant_id TEXT,
    device_id TEXT,
    transaction_ts TIMESTAMP,

    velocity_score INTEGER DEFAULT 0,
    geo_score INTEGER DEFAULT 0,
    device_score INTEGER DEFAULT 0,
    merchant_score INTEGER DEFAULT 0,
    amount_score INTEGER DEFAULT 0,

    fraud_score INTEGER DEFAULT 0,
    risk_band TEXT,

    main_reason TEXT,

    is_fraud_injected BOOLEAN,
    fraud_pattern TEXT,

    scored_at TIMESTAMP DEFAULT NOW()
);

-- 4.3- Fraud Alerts Table :

DROP TABLE IF EXISTS fraud.fraud_alerts;

CREATE TABLE fraud.fraud_alerts (
    alert_id BIGSERIAL PRIMARY KEY,

    transaction_id TEXT,
    sender_wallet_id TEXT,
    merchant_id TEXT,
    device_id TEXT,

    fraud_score INTEGER,
    risk_band TEXT,
    alert_reason TEXT,

    alert_status TEXT DEFAULT 'Open',
    assigned_to TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    closed_at TIMESTAMP
);


-------------------------------------------------------
--Creating Audit Tables in the audit schema :
-------------------------------------------------------

-- 5.1- ETL Run Log Table :

DROP TABLE IF EXISTS audit.etl_run_log;

CREATE TABLE audit.etl_run_log (
    run_id BIGSERIAL PRIMARY KEY,

    pipeline_name TEXT,
    step_name TEXT,
    status TEXT,

    started_at TIMESTAMP DEFAULT NOW(),
    finished_at TIMESTAMP,

    rows_inserted BIGINT,
    rows_updated BIGINT,
    rows_rejected BIGINT,

    notes TEXT
);

-- 5.2- Data Quality Check Log Table :

DROP TABLE IF EXISTS audit.data_quality_check_log;

CREATE TABLE audit.data_quality_check_log (
    check_id BIGSERIAL PRIMARY KEY,

    table_name TEXT,
    check_name TEXT,
    check_description TEXT,

    failed_rows BIGINT,
    checked_at TIMESTAMP DEFAULT NOW()
);

-- 5.3- Rejected Transactions Table :

DROP TABLE IF EXISTS audit.rejected_transactions;

CREATE TABLE audit.rejected_transactions (
    rejected_id BIGSERIAL PRIMARY KEY,

    transaction_id TEXT,
    sender_wallet_id TEXT,
    merchant_id TEXT,

    rejection_reason TEXT,
    raw_payload JSONB,

    rejected_at TIMESTAMP DEFAULT NOW()
);

