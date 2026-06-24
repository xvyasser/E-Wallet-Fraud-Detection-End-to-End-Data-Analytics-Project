CREATE OR REPLACE PROCEDURE fraud.build_transaction_features_for_month(
p_start_date DATE,
p_end_date DATE)

LANGUAGE plpgsql
AS $$
BEGIN

	WITH base AS(
		SELECT
		    t.transaction_id,
            t.sender_wallet_id,
            t.receiver_wallet_id,
            t.merchant_id,
            t.device_id,
            t.transaction_ts,
            t.transaction_amount,
            t.latitude,
            t.longitude,
			
			COUNT(*) OVER(PARTITION BY t.sender_wallet_id ORDER BY t.transaction_ts
						  RANGE BETWEEN INTERVAL '15 minutes' PRECEDING AND CURRENT ROW) AS txn_count_15m,

			COUNT(*) OVER(PARTITION BY t.sender_wallet_id ORDER BY t.transaction_ts
						  RANGE BETWEEN INTERVAL '1 hour' PRECEDING AND CURRENT ROW) AS txn_count_1h,
						  
			SUM(t.transaction_amount) OVER(PARTITION BY t.sender_wallet_id ORDER BY t.transaction_ts
											RANGE BETWEEN INTERVAL '1 hour' PRECEDING AND CURRENT ROW) AS amount_sum_1h,


			LAG(t.latitude) OVER(PARTITION BY t.sender_wallet_id ORDER BY t.transaction_ts) AS previous_latitude,

			LAG(t.longitude) OVER(PARTITION BY t.sender_wallet_id ORDER BY t.transaction_ts) AS previous_longitude,

			LAG(t.transaction_ts) OVER(PARTITION BY t.sender_wallet_id ORDER BY t.transaction_ts) AS previous_transaction_ts
	
		FROM dw.fact_transaction t
		WHERE t.transaction_ts>=p_start_date ::timestamp - INTERVAL '1 hour'
				AND t.transaction_ts<p_end_date::timestamp
	
	),

	feature_calc AS(
					SELECT
	          			  b.transaction_id,
          				  b.sender_wallet_id,
         				  b.merchant_id,
            			  b.device_id,
            			  b.transaction_ts,
                          b.txn_count_15m,
            			  b.txn_count_1h,
            			  b.amount_sum_1h,

						  COALESCE(sh.unique_receivers_1h, 0) AS unique_receivers_1h,

						  CASE WHEN
						  		b.latitude IS NOT NULL
								  AND b.longitude IS NOT NULL
								  AND b.previous_latitude IS NOT NULL
								  AND b.previous_longitude IS NOT NULL
								 THEN 
									 (
	                   				     6371 * 2 * ASIN(
							                            SQRT(
							                                POWER(SIN(RADIANS((b.latitude - b.previous_latitude) / 2)), 2)
							                                +
							                                COS(RADIANS(b.previous_latitude))
							                                * COS(RADIANS(b.latitude))
							                                * POWER(SIN(RADIANS((b.longitude - b.previous_longitude) / 2)), 2)
							                            )
							                        )
							                    )::numeric(12,2)
							      ELSE NULL
					      END AS distance_from_previous_txn_km,

						  CASE WHEN
						  		b.previous_transaction_ts IS NOT NULL
								THEN
									ROUND(EXTRACT(EPOCH FROM (b.transaction_ts - b.previous_transaction_ts))::numeric/60,2)
								ELSE NULL
						   END AS minutes_since_previous_txn,

						   COALESCE(dr.wallets_per_device,1) AS wallets_per_device,

						   COALESCE(mr.merchant_failed_rate, 0) AS merchant_failed_rate

					FROM base b

					LEFT JOIN fraud.sender_hourly_receiver_counts sh
					ON b.sender_wallet_id = sh.sender_wallet_id
					AND date_trunc('hour',b.transaction_ts) = sh.hour_bucket

					LEFT JOIN fraud.device_risk_base dr
					ON b.device_id = dr.device_id

					LEFT JOIN fraud.merchant_risk_base mr
                    ON b.merchant_id = mr.merchant_id

					)
		

		INSERT INTO fraud.transaction_features (
							        transaction_id,
							        sender_wallet_id,
							        merchant_id,
							        device_id,
							        transaction_ts,
							
							        txn_count_15m,
							        txn_count_1h,
							        amount_sum_1h,
							        unique_receivers_1h,
							
							        distance_from_previous_txn_km,
							        minutes_since_previous_txn,
							
							        wallets_per_device,
							        merchant_failed_rate
							    )
							    SELECT
							        transaction_id,
							        sender_wallet_id,
							        merchant_id,
							        device_id,
							        transaction_ts,
							
							        txn_count_15m,
							        txn_count_1h,
							        amount_sum_1h,
							        unique_receivers_1h,
							
							        distance_from_previous_txn_km,
							        minutes_since_previous_txn,
							
							        wallets_per_device,
							        merchant_failed_rate
							
    FROM feature_calc
    WHERE transaction_ts >= p_start_date::timestamp
      AND transaction_ts <  p_end_date::timestamp;

						   

END;
$$;

TRUNCATE TABLE fraud.transaction_features;


CALL fraud.build_transaction_features_for_month('2025-01-01', '2025-02-01');
CALL fraud.build_transaction_features_for_month('2025-02-01', '2025-03-01');
CALL fraud.build_transaction_features_for_month('2025-03-01', '2025-04-01');
CALL fraud.build_transaction_features_for_month('2025-04-01', '2025-05-01');
CALL fraud.build_transaction_features_for_month('2025-05-01', '2025-06-01');
CALL fraud.build_transaction_features_for_month('2025-06-01', '2025-07-01');
CALL fraud.build_transaction_features_for_month('2025-07-01', '2025-08-01');
CALL fraud.build_transaction_features_for_month('2025-08-01', '2025-09-01');
CALL fraud.build_transaction_features_for_month('2025-09-01', '2025-10-01');
CALL fraud.build_transaction_features_for_month('2025-10-01', '2025-11-01');
CALL fraud.build_transaction_features_for_month('2025-11-01', '2025-12-01');
CALL fraud.build_transaction_features_for_month('2025-12-01', '2026-01-01');

ANALYZE fraud.transaction_features;