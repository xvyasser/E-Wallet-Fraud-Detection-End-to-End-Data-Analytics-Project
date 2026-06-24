import math
import random
from datetime import datetime, timedelta

import numpy as np
import pandas as pd
from tqdm import tqdm

from config import (
    USER_COUNT,
    MERCHANT_COUNT,
    TRANSACTION_COUNT,
    TRANSACTION_CHUNK_SIZE,
    TRANSACTIONS_DIR,
    RAW_TRANSACTIONS_COLUMNS,
    RANDOM_SEED,
    EGYPT_LOCATIONS,
    TRANSACTION_TYPES,
    TRANSACTION_STATUSES,
    CHANNELS
)

random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)


def messy_timestamp(dt):
    """
    Return timestamp in mixed formats to simulate messy raw data.
    """
    r = random.random()

    if r < 0.02:
        return None
    elif r < 0.06:
        return dt.strftime("%d/%m/%Y %H:%M")
    elif r < 0.09:
        return dt.strftime("%m-%d-%Y %H:%M")
    else:
        return dt.strftime("%Y-%m-%d %H:%M:%S")


def random_transaction_datetime():
    """
    Generate dates within 2025.
    This matches the 2025 monthly partitions we created in PostgreSQL.
    """
    start = datetime(2025, 1, 1)
    end = datetime(2025, 12, 31, 23, 59, 59)

    seconds_between = int((end - start).total_seconds())
    random_seconds = random.randint(0, seconds_between)

    return start + timedelta(seconds=random_seconds)


def random_wallet_id():
    user_num = random.randint(1, USER_COUNT)
    return f"W{user_num:07d}"


def random_merchant_id():
    merchant_num = random.randint(1, MERCHANT_COUNT)
    return f"M{merchant_num:06d}"


def random_device_id():
    """
    Device IDs are intentionally fewer than users.
    This naturally creates some device sharing.
    """
    device_num = random.randint(1, max(1, int(USER_COUNT * 0.65)))
    return f"D{device_num:08d}"


def random_location():
    governorate = random.choice(list(EGYPT_LOCATIONS.keys()))
    base_lat = EGYPT_LOCATIONS[governorate]["lat"]
    base_lon = EGYPT_LOCATIONS[governorate]["lon"]

    lat = round(base_lat + random.uniform(-0.20, 0.20), 6)
    lon = round(base_lon + random.uniform(-0.20, 0.20), 6)

    return lat, lon


def messy_coordinate(value):
    """
    Mostly valid coordinates, sometimes NULL or invalid.
    """
    r = random.random()

    if r < 0.01:
        return None
    elif r < 0.012:
        return 999
    elif r < 0.014:
        return -999
    else:
        return value


def random_amount():
    """
    Normal transactions are mostly small/medium values.
    A few are intentionally messy.
    """
    r = random.random()

    if r < 0.005:
        return None
    elif r < 0.008:
        return -1 * round(random.uniform(10, 500), 2)
    elif r < 0.010:
        return "abc"
    elif r < 0.030:
        return round(random.uniform(5000, 50000), 2)
    else:
        return round(random.uniform(5, 1500), 2)


def choose_fraud_pattern():
    """
    Most rows are normal.
    A small percentage has injected fraud patterns.
    """
    r = random.random()

    if r < 0.003:
        return "smurfing"
    elif r < 0.005:
        return "geo_deviation"
    elif r < 0.008:
        return "merchant_abuse"
    elif r < 0.010:
        return "device_sharing"
    else:
        return "normal"


def build_normal_transaction(global_txn_num, source_file):
    transaction_id = f"T{global_txn_num:012d}"

    sender_wallet = random_wallet_id()
    receiver_wallet = random_wallet_id()

    # Avoid sender = receiver when possible.
    if receiver_wallet == sender_wallet:
        receiver_wallet = random_wallet_id()

    transaction_type = random.choice(TRANSACTION_TYPES)

    # Merchant ID only makes sense for merchant-like transactions.
    if transaction_type in ["MERCHANT_PAYMENT", "merchant", "payment", "BILL_PAYMENT", "bill", "utility", "TOPUP", "airtime", "mobile_topup"]:
        merchant_id = random_merchant_id()
    else:
        merchant_id = None

    tx_dt = random_transaction_datetime()
    lat, lon = random_location()

    row = {
        "raw_transaction_id": transaction_id,
        "transaction_id": transaction_id,
        "sender_wallet_id": sender_wallet,
        "receiver_wallet_id": receiver_wallet,
        "merchant_id": merchant_id,
        "transaction_type": transaction_type,
        "transaction_status": random.choice(TRANSACTION_STATUSES),
        "transaction_amount": random_amount(),
        "currency": random.choice(["EGP", "egp", "EGP ", None]),
        "transaction_ts": messy_timestamp(tx_dt),
        "latitude": messy_coordinate(lat),
        "longitude": messy_coordinate(lon),
        "device_id": random_device_id(),
        "channel": random.choice(CHANNELS),
        "is_fraud_injected": "false",
        "fraud_pattern": "normal",
        "source_file": source_file
    }

    return row


def apply_fraud_pattern(row, pattern):
    """
    Modify a normal row into a suspicious row.
    This keeps the script simple but still useful for the portfolio.
    """

    if pattern == "smurfing":
        row["transaction_amount"] = round(random.uniform(50, 250), 2)
        row["transaction_type"] = random.choice(["P2P", "wallet_transfer", "transfer"])
        row["transaction_status"] = random.choice(["SUCCESS", "success", "done"])
        row["merchant_id"] = None

    elif pattern == "geo_deviation":
        # Put transaction in a far-away governorate.
        row["latitude"] = round(random.choice([24.0889, 31.2001, 27.2579]), 6)
        row["longitude"] = round(random.choice([32.8998, 29.9187, 33.8116]), 6)
        row["transaction_status"] = random.choice(["SUCCESS", "success", "done"])

    elif pattern == "merchant_abuse":
        row["transaction_type"] = random.choice(["MERCHANT_PAYMENT", "merchant", "payment"])
        row["merchant_id"] = random_merchant_id()
        row["transaction_amount"] = round(random.uniform(20, 300), 2)
        row["transaction_status"] = random.choice(["FAILED", "failed", "declined", "rejected", "SUCCESS"])

    elif pattern == "device_sharing":
        # Force many transactions onto a small set of suspicious devices.
        suspicious_device_num = random.randint(1, 200)
        row["device_id"] = f"D_RISK_{suspicious_device_num:04d}"
        row["transaction_status"] = random.choice(["SUCCESS", "success", "FAILED", "failed"])

    row["is_fraud_injected"] = "true"
    row["fraud_pattern"] = pattern

    return row


def generate_transaction_chunk(chunk_id, start_txn_num, row_count):
    source_file = f"transactions_{chunk_id:04d}.csv"

    rows = []

    for i in range(row_count):
        global_txn_num = start_txn_num + i
        row = build_normal_transaction(global_txn_num, source_file)

        pattern = choose_fraud_pattern()
        if pattern != "normal":
            row = apply_fraud_pattern(row, pattern)

        rows.append(row)

    df = pd.DataFrame(rows)

    # Add duplicate transactions inside the chunk.
    duplicate_count = max(1, int(row_count * 0.002))
    duplicates = df.sample(duplicate_count, random_state=RANDOM_SEED + chunk_id)
    df = pd.concat([df, duplicates], ignore_index=True)

    # Add a few messy duplicate transaction IDs with different raw_transaction_id.
    # This helps us test deduplication later.
    if len(df) > 10:
        sample_idx = df.sample(max(1, int(row_count * 0.001)), random_state=chunk_id).index
        df.loc[sample_idx, "raw_transaction_id"] = df.loc[sample_idx, "raw_transaction_id"].astype(str) + "_DUP"

    # Make sure column names and order match PostgreSQL staging.
    df = df[RAW_TRANSACTIONS_COLUMNS]

    return df


def generate_transactions():
    total_chunks = math.ceil(TRANSACTION_COUNT / TRANSACTION_CHUNK_SIZE)

    current_txn_num = 1

    for chunk_id in tqdm(range(total_chunks), desc="Generating transaction chunks"):
        remaining = TRANSACTION_COUNT - ((chunk_id) * TRANSACTION_CHUNK_SIZE)
        row_count = min(TRANSACTION_CHUNK_SIZE, remaining)

        df = generate_transaction_chunk(
            chunk_id=chunk_id,
            start_txn_num=current_txn_num,
            row_count=row_count
        )

        output_path = TRANSACTIONS_DIR / f"transactions_{chunk_id:04d}.csv"
        df.to_csv(output_path, index=False, encoding="utf-8")

        current_txn_num += row_count

        print(f"Generated {output_path} with {len(df):,} rows including duplicates")

    print("Done generating transaction files.")


if __name__ == "__main__":
    generate_transactions()
