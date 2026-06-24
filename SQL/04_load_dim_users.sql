TRUNCATE TABLE dw.dim_user RESTART IDENTITY CASCADE;

--------------------------------------------------------------------
--Cleaning the staging.raw_users table to load it into dw.dim_user:
--------------------------------------------------------------------

WITH cleaned_user_table AS(

SELECT
	raw_user_id,
	
	NULLIF(TRIM(wallet_id),'') AS wallet_id,
	NULLIF(TRIM(full_name),'') AS full_name,
	NULLIF(TRIM(phone_number),'') AS phone_number,
	NULLIF(TRIM(national_id_last4),'') AS national_id_last4,

	CASE
		WHEN LOWER(TRIM(gender)) IN ('m','male') THEN 'Male'
		WHEN LOWER(TRIM(gender)) IN ('f','female') THEN 'Female'
		ELSE 'Unknown'
	END AS gender,

	CASE
		WHEN date_of_birth ~ '^\d{4}-\d{2}-\d{2}$' THEN date_of_birth::date
		ELSE NULL
	END AS date_of_birth,

	 NULLIF(TRIM(governorate), '') AS governorate,
     NULLIF(TRIM(city), '') AS city,

	 CASE
	 	WHEN signup_ts ~ '^\d{4}-\d{2}-\d{2}' THEN signup_ts::timestamp
		WHEN signup_ts ~ '^\d{2}/\d{2}/\d{4}' THEN TO_TIMESTAMP(signup_ts,'DD/MM/YYYY HH24:MI')
		WHEN signup_ts ~ '^\d{2}-\d{2}-\d{4}' THEN TO_TIMESTAMP(signup_ts,'MM-DD-YYYY HH24:MI')
		ELSE NULL
	 END AS signup_ts,

	  CASE
            WHEN LOWER(TRIM(kyc_status)) = 'verified' THEN 'Verified'
            WHEN LOWER(TRIM(kyc_status)) = 'pending' THEN 'Pending'
            WHEN LOWER(TRIM(kyc_status)) = 'rejected' THEN 'Rejected'
            ELSE 'Unknown'
       END AS kyc_status,

	   CASE
            WHEN LOWER(TRIM(account_status)) = 'active' THEN 'Active'
            WHEN LOWER(TRIM(account_status)) IN ('suspended', 'blocked') THEN 'Suspended'
            WHEN LOWER(TRIM(account_status)) = 'closed' THEN 'Closed'
            ELSE 'Unknown'
       END AS account_status,

	   loaded_at,

        MD5(
            COALESCE(full_name, '') ||
            COALESCE(phone_number, '') ||
            COALESCE(governorate, '') ||
            COALESCE(city, '') ||
            COALESCE(kyc_status, '') ||
            COALESCE(account_status, '')
        ) AS source_hash

    FROM staging.raw_users
    WHERE NULLIF(TRIM(wallet_id), '') IS NOT NULL
),

Deduped AS (

		SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY wallet_id ORDER BY loaded_at DESC, signup_ts DESC NULLS LAST) AS rn
		FROM cleaned_user_table
)


INSERT INTO dw.dim_user (
    wallet_id,
    full_name,
    phone_number,
    national_id_last4,
    gender,
    date_of_birth,
    governorate,
    city,
    signup_ts,
    kyc_status,
    account_status,
    valid_from,
    valid_to,
    is_current,
    source_hash
)
SELECT
    wallet_id,
    full_name,
    phone_number,
    national_id_last4,
    gender,
    date_of_birth,
    governorate,
    city,
    signup_ts,
    kyc_status,
    account_status,
    COALESCE(signup_ts, NOW()) AS valid_from,
    NULL AS valid_to,
    TRUE AS is_current,
    source_hash
FROM deduped
WHERE rn = 1;

ANALYZE dw.dim_user;