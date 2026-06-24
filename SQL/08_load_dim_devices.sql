TRUNCATE TABLE dw.dim_device RESTART IDENTITY CASCADE;

INSERT INTO dw.dim_device(

device_id,
device_type,
os_name,
first_seen_ts,
last_seen_ts
)

SELECT

	device_id,
	'Unknown' AS device_type,
	'Unknown' AS os_name,
	MIN(parsed_transaction_ts) AS first_seen_ts,
	MAX(parsed_transaction_ts) AS last_seen_ts

FROM staging.clean_transactions_work
WHERE device_id IS NOT NULL
  AND parsed_transaction_ts IS NOT NULL
GROUP BY device_id;

ANALYZE dw.dim_device; 