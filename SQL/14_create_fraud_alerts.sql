TRUNCATE TABLE fraud.fraud_alerts RESTART IDENTITY;

INSERT INTO fraud.fraud_alerts (
    transaction_id,
    sender_wallet_id,
    merchant_id,
    device_id,
    fraud_score,
    risk_band,
    alert_reason,
    alert_status
)
SELECT
    transaction_id,
    sender_wallet_id,
    merchant_id,
    device_id,
    fraud_score,
    risk_band,
    main_reason AS alert_reason,
    'Open' AS alert_status
FROM fraud.transaction_fraud_scores
WHERE risk_band IN ('High', 'Critical');

ANALYZE fraud.fraud_alerts;