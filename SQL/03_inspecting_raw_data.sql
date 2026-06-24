-----------------------------------
--Inspecting the raw data :
-----------------------------------

SELECT COUNT(*) AS raw_users
FROM staging.raw_users;
--No. of raw users loaded -> 502500

SELECT COUNT(*) AS raw_merchants
FROM staging.raw_merchants;
--No. of raw merchants loaded -> 15150

SELECT COUNT(*) AS raw_transactions
FROM staging.raw_transactions;
--No. of raw transactions loaded -> 50100000

---------------------------
--Checking Duplicates :
---------------------------

--Checking Duplicate Wallets (2496 Dupes) :

WITH duplicate_wallets AS(
	SELECT 
		wallet_id,
		raw_user_id,
		COUNT(*) OVER(PARTITION BY wallet_id) AS duplicates,
		ROW_NUMBER() OVER(PARTITION BY wallet_id ORDER BY raw_user_id) as rn
	FROM staging.raw_users
	WHERE NULLIF(TRIM(wallet_id),'') IS NOT NULL
)
SELECT
	rn,
	wallet_id,
	raw_user_id,
	duplicates
FROM duplicate_wallets
WHERE rn>1
ORDER BY duplicates DESC , wallet_id;

--Checking Duplicate Transactions (100000 Dupes) :

WITH duplicate_transactions AS(

SELECT
	transaction_id,
	raw_transaction_id,
	sender_wallet_id,
	receiver_wallet_id,
	COUNT(*) OVER(PARTITION BY transaction_id) as duplicates,
	ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY raw_transaction_id) as rn
FROM staging.raw_transactions
WHERE NULLIF(TRIM(transaction_id),'') IS NOT NULL
)
SELECT
	rn
	transaction_id,
	raw_transaction_id,
	duplicates
FROM duplicate_transactions
WHERE rn>1
ORDER BY duplicates DESC,transaction_id;

--Checking Duplicate Merchants (150 Dupes) :

WITH duplicate_merchants AS(
SELECT
	merchant_id,
	raw_merchant_id,
	COUNT(*) OVER(PARTITION BY merchant_id) AS duplicates,
	ROW_NUMBER() OVER(PARTITION BY merchant_id ORDER BY raw_merchant_id) AS rn
FROM staging.raw_merchants
WHERE NULLIF(TRIM(merchant_id),'') IS NOT NULL
)
SELECT
	rn,
	merchant_id,
	raw_merchant_id,
	duplicates
FROM duplicate_merchants
WHERE rn>1
ORDER BY duplicates DESC, merchant_id;


--Checking for messy amounts :

SELECT
    transaction_amount,
    COUNT(*) AS row_count
FROM staging.raw_transactions
GROUP BY transaction_amount
ORDER BY row_count DESC;

--Checking fraud pattern distribution :

SELECT
	fraud_pattern,
	COUNT(*) as count
FROM staging.raw_transactions
GROUP BY fraud_pattern
ORDER BY count DESC;


-------------------------------
--Checking Missing Values :
-------------------------------

--Checking Missing Values in the Raw Users Table :

SELECT
	COUNT(*) AS total_rows,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(wallet_id),'') IS NULL) AS missing_wallet_id -- -> 1000,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(full_name),'') IS NULL) AS missing_full_name -- -> 4935,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(phone_number),'') IS NULL) AS missing_phone_number -- -> 15330,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(signup_ts),'') IS NULL) AS missing_signup_ts -- -> 14985,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(kyc_status),'') IS NULL) AS missing_kyc_status -- -> 83744,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(account_status),'') IS NULL) AS missing_account_status -- -> 0
FROM staging.raw_users;

---------------------------------------
--User Categorical Value Inspection :
---------------------------------------

-- Gender (M,F,Null,Female,Male):

SELECT
	gender,
	COUNT(*)AS Count
FROM staging.raw_users
GROUP BY gender
ORDER BY Count;

-- KYC Status (Pending,pending,NULL,Verified,verified,Rejected):

SELECT
	kyc_status,
	COUNT(*) AS Count
FROM staging.raw_users
GROUP BY kyc_status
ORDER BY Count;

--Account Status (Suspended,active,Closed,Active,blocked):

SELECT
	account_status,
	COUNT(*) AS Count
FROM staging.raw_users
GROUP BY account_status
ORDER BY Count;

-- Governorate (Nulls):

SELECT
	governorate,
	COUNT(*) AS Count
FROM staging.raw_users
GROUP BY governorate
ORDER BY Count;


-------------------------------------
--User Timestamp Format Inspection :
-------------------------------------

SELECT
	CASE 
		WHEN signup_ts IS NULL THEN 'NULL' -- -> 14985
		WHEN signup_ts ~ '^\d{4}-\d{2}-\d{2}' THEN 'YYYY-MM-DD format' -- -> 442359
		WHEN signup_ts ~ '^\d{2}/\d{2}/\d{4}' THEN 'DD-MM-YYYY format' -- -> 25066
		WHEN signup_ts ~ '^\d{2}-\d{2}-\d{4}' THEN 'MM-DD-YYYY format' -- -> 20090
		ELSE 'Other / Invalid'
	END AS signup_ts_format,
	COUNT(*) AS Count
FROM staging.raw_users
GROUP BY signup_ts_format
ORDER BY COUNT DESC;


-------------------------------
--Merchant Missing Values:
-------------------------------

SELECT
	COUNT(*) AS Count,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(merchant_id),'') IS NULL) AS missing_merchant_id -- -> 27,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(merchant_name),'') IS NULL) AS missing_merchant_name -- -> 154,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(merchant_category),'') IS NULL) AS missing_merchant_category -- -> 0,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(governorate),'') IS NULL) AS missing_governorate -- -> 163,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(latitude),'') IS NULL) AS missing_latitude -- -> 344,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(longitude),'') IS NULL) AS missing_longitude -- -> 309,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(onboarding_ts),'') IS NULL) AS missing_onboarding_ts -- -> 454,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(merchant_status),'') IS NULL) AS missing_merchant_status -- -> 2517
FROM staging.raw_merchants;

---------------------------------
--Merchant Category Messiness:
---------------------------------
/* healthcare , courses, restaurant, bills, ride hailing, electronics,
   gas , supermarket, FOOD , water , F&B , mobile topup, airtime , 
   electricity, Electronics , unknown, apparel , transport , transport,
   pharmacy , Groceries , restaurants, Food, topup, mobile shop, fashion,
   food , clothes , grocery , bus
*/


SELECT
    merchant_category,
    COUNT(*) AS row_count
FROM staging.raw_merchants
GROUP BY merchant_category
ORDER BY row_count DESC;

---------------------------------
--Merchant Coordinate Quality :
---------------------------------

SELECT
    COUNT(*) AS total_merchants,

    COUNT(*) FILTER (
        WHERE latitude IS NULL
           OR NULLIF(TRIM(latitude), '') IS NULL
    ) AS missing_latitude -- -> 344,

    COUNT(*) FILTER (
        WHERE latitude IS NOT NULL
          AND latitude !~ '^-?\d+(\.\d+)?$'
    ) AS non_numeric_latitude -- ->0,

    COUNT(*) FILTER (
        WHERE latitude ~ '^-?\d+(\.\d+)?$'
          AND latitude::numeric NOT BETWEEN 22 AND 32
    ) AS outside_egypt_latitude -- ->168,

    COUNT(*) FILTER (
        WHERE longitude IS NULL
           OR NULLIF(TRIM(longitude), '') IS NULL
    ) AS missing_longitude -- -> 309,

    COUNT(*) FILTER (
        WHERE longitude IS NOT NULL
          AND longitude !~ '^-?\d+(\.\d+)?$'
    ) AS non_numeric_longitude -- -> 0,

    COUNT(*) FILTER (
        WHERE longitude ~ '^-?\d+(\.\d+)?$'
          AND longitude::numeric NOT BETWEEN 24 AND 37
    ) AS outside_egypt_longitude -- -> 161

FROM staging.raw_merchants;


------------------------------------
--Transaction Missing Values :
------------------------------------

SELECT
	COUNT(*) AS Count,
	COUNT(*) FILTER(WHERE NULLIF(TRIM(transaction_id),'') IS NULL) missing_merchant_id, -- -> 0
	COUNT(*) FILTER(WHERE NULLIF(TRIM(sender_wallet_id),'') IS NULL) missing_sender_wallet_id, -- -> 0
	COUNT(*) FILTER(WHERE NULLIF(TRIM(receiver_wallet_id),'') IS NULL) missing_receiver_wallet_id, -- -> 0
	COUNT(*) FILTER(WHERE NULLIF(TRIM(transaction_amount),'') IS NULL) missing_transaction_amount, -- -> 248243
	COUNT(*) FILTER(WHERE NULLIF(TRIM(transaction_ts),'') IS NULL) missing_transaction_ts, -- -> 1001152
	COUNT(*) FILTER(WHERE NULLIF(TRIM(device_id),'') IS NULL) missing_device_id, -- -> 0
	COUNT(*) FILTER(WHERE NULLIF(TRIM(transaction_type),'') IS NULL) missing_transaction_type, -- -> 0
	COUNT(*) FILTER(WHERE NULLIF(TRIM(transaction_status),'') IS NULL) missing_transaction_status -- -> 0
FROM staging.raw_transactions;


--------------------------------------
--Transaction Amount Quality :
--------------------------------------

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE transaction_amount ~ '^-?\d+(\.\d+)?$'
    ) AS numeric_amounts, --> 49751724

    COUNT(*) FILTER (
        WHERE transaction_amount IS NULL
           OR transaction_amount !~ '^-?\d+(\.\d+)?$'
    ) AS non_numeric_or_missing_amounts, --> 348276

    COUNT(*) FILTER (
        WHERE transaction_amount ~ '^-?\d+(\.\d+)?$'
          AND transaction_amount::numeric < 0
    ) AS negative_amounts, --> 149451

    COUNT(*) FILTER (
        WHERE transaction_amount ~ '^-?\d+(\.\d+)?$'
          AND transaction_amount::numeric = 0
    ) AS zero_amounts, --> 0

    COUNT(*) FILTER (
        WHERE transaction_amount ~ '^-?\d+(\.\d+)?$'
          AND transaction_amount::numeric > 50000
    ) AS very_high_amounts --> 0

FROM staging.raw_transactions;

-------------------------------------
--Transaction Amount Distribution:
-------------------------------------

SELECT
	MIN(transaction_amount::numeric) AS min_amount, --> 5.0
	MAX(transaction_amount::numeric) AS max_amount, --> 50000.0
	AVG(transaction_amount::numeric) AS avg_amount, --> 1286.5692961907209373
	PERCENTILE_CONT(0.50) WITHIN GROUP(ORDER BY transaction_amount::numeric) AS median_amount, --> 763.32
	PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY transaction_amount::numeric) AS p95_amount, --> 1454.13
	PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY transaction_amount::numeric) AS p99_amount --> 27629.889600000082
FROM staging.raw_transactions
WHERE transaction_amount  ~ '^-?\d+(\.\d+)?$' AND
	  transaction_amount::numeric>0;	


---------------------------------------------
--Transaction Timestamp Format Inspection :
---------------------------------------------

SELECT 
	CASE
		WHEN transaction_ts IS NULL THEN 'NULL' --> 1001152
		WHEN transaction_ts ~ '^\d{4}-\d{2}-\d{2}' THEN 'YYYY-MM-DD format' --> 45588830
		WHEN transaction_ts ~ '^\d{2}/\d{2}/\d{4}' THEN 'DD-MM-YYYY format' --> 2005021
		WHEN transaction_ts ~ '^\d{2}-\d{2}-\d{4}' THEN 'MM-DD-YYYY format' --> 1504997
		ELSE 'Other / Invalid'
	END AS timestamp_format,
	COUNT(*) AS Count
FROM staging.raw_transactions
GROUP BY timestamp_format
ORDER BY Count DESC;


------------------------------------------
--Transaction Type Mapping Coverage :
------------------------------------------

/* 
"payment"
"merchant"
"P2P"
"MERCHANT_PAYMENT"
"wallet_transfer"
"transfer"
"BILL_PAYMENT"
"cashout"
"TOPUP"
"CASH_OUT"
"bill"
"utility"
"cashin"
"mobile_topup"
"CASH_IN"
"withdrawal"
"deposit"
"airtime"
*/
SELECT
	transaction_type,
	COUNT(*) AS Count
FROM staging.raw_transactions
GROUP BY transaction_type
ORDER BY Count DESC;

----------------------------------------
--Transaction Status Mapping Coverage:
----------------------------------------

/* 
"SUCCESS"
"success"
"done"
"FAILED"
"failed"
"rejected"
"declined"
"pending"
"fail"
"Completed"
"PENDING"
"succeeded"
"REVERSED"
"reversed"
"refund"
*/

SELECT
    transaction_status,
    COUNT(*) AS row_count
FROM staging.raw_transactions
GROUP BY transaction_status
ORDER BY row_count DESC;


--------------------------
--Currency Quality :
--------------------------

SELECT
    currency,
    COUNT(*) AS row_count
FROM staging.raw_transactions
GROUP BY currency
ORDER BY row_count DESC;

------------------------------------
--Transaction Coordinate Quality:
------------------------------------

SELECT
    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE latitude IS NULL
           OR NULLIF(TRIM(latitude), '') IS NULL
    ) AS missing_latitude, --> 499750

    COUNT(*) FILTER (
        WHERE latitude IS NOT NULL
          AND latitude !~ '^-?\d+(\.\d+)?$'
    ) AS non_numeric_latitude, --> 0

    COUNT(*) FILTER (
        WHERE latitude ~ '^-?\d+(\.\d+)?$'
          AND latitude::numeric NOT BETWEEN 22 AND 32
    ) AS outside_egypt_latitude, --> 200099

    COUNT(*) FILTER (
        WHERE longitude IS NULL
           OR NULLIF(TRIM(longitude), '') IS NULL
    ) AS missing_longitude, --> 499430

    COUNT(*) FILTER (
        WHERE longitude IS NOT NULL
          AND longitude !~ '^-?\d+(\.\d+)?$'
    ) AS non_numeric_longitude, --> 0

    COUNT(*) FILTER (
        WHERE longitude ~ '^-?\d+(\.\d+)?$'
          AND longitude::numeric NOT BETWEEN 24 AND 37
    ) AS outside_egypt_longitude --> 199331

FROM staging.raw_transactions;

--------------------------------------------------------
--Relationship Check: Transactions Referencing Users :
--------------------------------------------------------
--For sender wallets:

SELECT COUNT(*) AS transactions_with_unknown_sender --> 99542
FROM staging.raw_transactions rt
LEFT JOIN staging.raw_users ru
    ON rt.sender_wallet_id = ru.wallet_id
WHERE NULLIF(TRIM(rt.sender_wallet_id), '') IS NOT NULL
  AND ru.wallet_id IS NULL; 

--For receiver wallets:

SELECT COUNT(*) AS transactions_with_unknown_receiver --> 99878
FROM staging.raw_transactions rt
LEFT JOIN staging.raw_users ru
    ON rt.receiver_wallet_id = ru.wallet_id
WHERE NULLIF(TRIM(rt.receiver_wallet_id), '') IS NOT NULL
  AND ru.wallet_id IS NULL;


-----------------------------------
--Device Sharing Preview :
-----------------------------------
SELECT
	device_id,
	COUNT(*) AS transactions_count,
	COUNT(DISTINCT sender_wallet_id) AS distinct_wallets
FROM staging.raw_transactions
WHERE NULLIF(TRIM(device_id),'') IS NOT NULL
GROUP BY device_id
ORDER BY distinct_wallets DESC, transactions_count DESC
LIMIT 20;



