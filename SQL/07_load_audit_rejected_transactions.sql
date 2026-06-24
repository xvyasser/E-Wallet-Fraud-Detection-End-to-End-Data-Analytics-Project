TRUNCATE TABLE audit.rejected_transactions RESTART IDENTITY ;

INSERT INTO audit.rejected_transactions(

transaction_id,
sender_wallet_id,
merchant_id,
rejection_reason,
raw_payload

)

SELECT
	transaction_id,
	sender_wallet_id,
	merchant_id,
	rejection_reason,
	TO_JSNOB(c.*) AS raw_payload

FROM staging.clean_transactions_work c
WHERE validation_status = 'Rejected';