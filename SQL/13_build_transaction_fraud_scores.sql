CREATE OR REPLACE PROCEDURE fraud.score_transactions_for_month(
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE 'Scoring transactions from % to %', p_start_date, p_end_date;

    WITH base AS (
        SELECT
            f.transaction_id,
            f.sender_wallet_id,
            f.merchant_id,
            f.device_id,
            f.transaction_ts,

            f.txn_count_15m,
            f.txn_count_1h,
            f.amount_sum_1h,
            f.unique_receivers_1h,
            f.distance_from_previous_txn_km,
            f.minutes_since_previous_txn,
            f.wallets_per_device,
            f.merchant_failed_rate,

            t.transaction_amount

        FROM fraud.transaction_features f

        JOIN dw.fact_transaction t
            ON f.transaction_id = t.transaction_id

        WHERE f.transaction_ts >= p_start_date::timestamp
          AND f.transaction_ts <  p_end_date::timestamp
    ),

    component_scores AS (
        SELECT
            *,

            LEAST(
                55,
                CASE
                    WHEN txn_count_15m >= 15 THEN 20
                    WHEN txn_count_15m >= 10 THEN 15
                    WHEN txn_count_15m >= 5  THEN 8
                    ELSE 0
                END
                +
                CASE
                    WHEN txn_count_1h >= 40 THEN 15
                    WHEN txn_count_1h >= 25 THEN 10
                    WHEN txn_count_1h >= 12 THEN 5
                    ELSE 0
                END
                +
                CASE
                    WHEN amount_sum_1h >= 50000 THEN 20
                    WHEN amount_sum_1h >= 20000 THEN 12
                    WHEN amount_sum_1h >= 10000 THEN 6
                    ELSE 0
                END
            ) AS velocity_score,

            CASE
                WHEN distance_from_previous_txn_km >= 250
                 AND minutes_since_previous_txn <= 30
                    THEN 35

                WHEN distance_from_previous_txn_km >= 150
                 AND minutes_since_previous_txn <= 30
                    THEN 25

                WHEN distance_from_previous_txn_km >= 75
                 AND minutes_since_previous_txn <= 20
                    THEN 15

                WHEN distance_from_previous_txn_km >= 50
                 AND minutes_since_previous_txn <= 15
                    THEN 10

                ELSE 0
            END AS geo_score,

            CASE
                WHEN wallets_per_device >= 50 THEN 20
                WHEN wallets_per_device >= 30 THEN 15
                WHEN wallets_per_device >= 15 THEN 10
                WHEN wallets_per_device >= 5  THEN 5
                ELSE 0
            END AS device_score,

            CASE
                WHEN merchant_failed_rate >= 0.40 THEN 15
                WHEN merchant_failed_rate >= 0.25 THEN 10
                WHEN merchant_failed_rate >= 0.15 THEN 5
                ELSE 0
            END AS merchant_score,

            CASE
                WHEN transaction_amount >= 50000 THEN 20
                WHEN transaction_amount >= 20000 THEN 12
                WHEN transaction_amount >= 10000 THEN 6
                ELSE 0
            END AS amount_score,

            CASE
                WHEN unique_receivers_1h >= 20 THEN 25
                WHEN unique_receivers_1h >= 10 THEN 15
                WHEN unique_receivers_1h >= 5  THEN 8
                ELSE 0
            END AS receiver_score

        FROM base
    ),

    final_scores AS (
        SELECT
            *,

            LEAST(
                100,
                velocity_score
                + geo_score
                + device_score
                + merchant_score
                + amount_score
                + receiver_score
            ) AS fraud_score

        FROM component_scores
    )

    INSERT INTO fraud.transaction_fraud_scores (
        transaction_id,
        sender_wallet_id,
        merchant_id,
        device_id,
        transaction_ts,

        velocity_score,
        geo_score,
        device_score,
        merchant_score,
        amount_score,

        fraud_score,
        risk_band,
        main_reason
    )
    SELECT
        transaction_id,
        sender_wallet_id,
        merchant_id,
        device_id,
        transaction_ts,

        velocity_score,
        geo_score,
        device_score,
        merchant_score,
        amount_score,

        fraud_score,

		CASE
		    WHEN fraud_score >= 61 THEN 'Critical'
		    WHEN fraud_score >= 41 THEN 'High'
		    WHEN fraud_score >= 26 THEN 'Medium'
		    ELSE 'Low'
		END AS risk_band,

        CASE
            WHEN geo_score >= 25
                THEN 'Impossible travel'

            WHEN receiver_score >= 15
                THEN 'Smurfing behavior'

            WHEN device_score >= 15
                THEN 'Shared device ring'

            WHEN merchant_score >= 10
                THEN 'Merchant abuse'

            WHEN velocity_score >= 30
                THEN 'High velocity behavior'

            WHEN amount_score >= 12
                THEN 'Unusual transaction amount'

            ELSE 'No major risk reason'
        END AS main_reason

    FROM final_scores;

    RAISE NOTICE 'Finished scoring transactions from % to %', p_start_date, p_end_date;

END;
$$;

CALL fraud.score_transactions_for_month('2025-01-01', '2025-02-01');
CALL fraud.score_transactions_for_month('2025-02-01', '2025-03-01');
CALL fraud.score_transactions_for_month('2025-03-01', '2025-04-01');
CALL fraud.score_transactions_for_month('2025-04-01', '2025-05-01');
CALL fraud.score_transactions_for_month('2025-05-01', '2025-06-01');
CALL fraud.score_transactions_for_month('2025-06-01', '2025-07-01');
CALL fraud.score_transactions_for_month('2025-07-01', '2025-08-01');
CALL fraud.score_transactions_for_month('2025-08-01', '2025-09-01');
CALL fraud.score_transactions_for_month('2025-09-01', '2025-10-01');
CALL fraud.score_transactions_for_month('2025-10-01', '2025-11-01');
CALL fraud.score_transactions_for_month('2025-11-01', '2025-12-01');
CALL fraud.score_transactions_for_month('2025-12-01', '2026-01-01');

ANALYZE fraud.transaction_fraud_scores;
