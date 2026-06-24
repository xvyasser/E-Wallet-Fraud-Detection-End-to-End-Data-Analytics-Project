TRUNCATE TABLE dw.dim_merchant RESTART IDENTITY CASCADE;

WITH cleaned_merchant_table AS(

SELECT
	rm.raw_merchant_id,

	NULLIF(TRIM(rm.merchant_id),'') AS merchant_id,
	NULLIF(TRIM(rm.merchant_name),'') AS merchant_name,
	NULLIF(TRIM(rm.merchant_category),'') AS raw_category,
	
	COALESCE(mcm.normalized_category,'Unknown') AS normalized_category,
	COALESCE(mcm.category_group,'Unknown') AS category_group,

	NULLIF(TRIM(rm.governorate),'') AS governorate,
	NULLIF(TRIM(rm.city),'') AS city,

	CASE
		WHEN rm.latitude ~ '^-?\d+(\.\d+)?$' 
			AND rm.latitude::numeric BETWEEN 22 AND 32
			THEN rm.latitude::numeric(9,6)
		ELSE NULL
	END AS latitude,

	CASE
		WHEN rm.longitude ~ '^-?\d+(\.\d+)?$'
			AND rm.longitude::numeric BETWEEN 24 AND 37
			THEN rm.longitude::numeric(9,6)
		ELSE NULL
	END AS longitude,


	CASE
		WHEN rm.onboarding_ts ~ '^\d{4}-\d{2}-\d{2}'
			THEN rm.onboarding_ts::timestamp
		WHEN rm.onboarding_ts ~'^\d{2}/\d{2}/\d{4}'
			THEN TO_TIMESTAMP(rm.onboarding_ts,'DD/MM/YYYY HH24:MI')
		WHEN rm.onboarding_ts ~ '^\d{2}-\d{2}-\d{4}'
			THEN TO_TIMESTAMP(rm.onboarding_ts,'MM-DD-YYYY HH24:MI')
		ELSE NULL
	END AS onboarding_ts,

	CASE
		WHEN LOWER(TRIM(rm.merchant_status)) = 'active' THEN 'Active'
		WHEN LOWER(TRIM(rm.merchant_status)) IN ('blocked','suspended') THEN 'Suspended'
		WHEN LOWER(TRIM(rm.merchant_status)) = 'closed' THEN 'Closed'
		ELSE NULL
	END AS merchant_status,

	rm.loaded_at,

	MD5(	
			COALESCE(rm.merchant_name, '') ||
            COALESCE(rm.merchant_category, '') ||
            COALESCE(rm.governorate, '') ||
            COALESCE(rm.city, '') ||
            COALESCE(rm.merchant_status, '')
        ) 	AS source_hash

FROM staging.raw_merchants rm
LEFT JOIN ref.merchant_category_map mcm
ON rm.merchant_category = mcm.raw_category

WHERE NULLIF(TRIM(rm.merchant_id),'') IS NOT NULL
),


Deduped AS(
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY merchant_id ORDER BY loaded_at DESC, onboarding_ts DESC NULLS LAST) AS rn
FROM cleaned_merchant_table
)

INSERT INTO dw.dim_merchant(
	merchant_id,
	merchant_name,
	raw_category,
	normalized_category,
	category_group,
	governorate,
	city,
	latitude,
	longitude,
	merchant_status,
	onboarding_ts,
	valid_from,
	valid_to,
	is_current,
	source_hash

)

SELECT
	merchant_id,
	merchant_name,
	raw_category,
	normalized_category,
	category_group,
	governorate,
	city,
	latitude,
	longitude,
	merchant_status,
	onboarding_ts,
	COALESCE(onboarding_ts,NOW()) AS valid_from,
	NULL AS valid_to,
	TRUE AS is_current,
	source_hash

FROM deduped
WHERE rn = 1;

ANALYZE dw.dim_merchant;