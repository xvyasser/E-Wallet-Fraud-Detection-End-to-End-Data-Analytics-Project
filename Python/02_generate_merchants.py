import random
from datetime import datetime, timedelta

import numpy as np
import pandas as pd
from faker import Faker
from tqdm import tqdm

from config import (
    MERCHANT_COUNT,
    MERCHANTS_DIR,
    RAW_MERCHANTS_COLUMNS,
    RANDOM_SEED,
    EGYPT_LOCATIONS,
    MERCHANT_NAME_PARTS,
    MESSY_MERCHANT_CATEGORIES
)

fake = Faker()
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)


def random_date(start_date, end_date):
    days_between = (end_date - start_date).days
    random_days = random.randint(0, days_between)
    return start_date + timedelta(days=random_days)


def messy_timestamp(dt):
    r = random.random()

    if r < 0.03:
        return None
    elif r < 0.08:
        return dt.strftime("%d/%m/%Y %H:%M")
    elif r < 0.12:
        return dt.strftime("%m-%d-%Y %H:%M")
    else:
        return dt.strftime("%Y-%m-%d %H:%M:%S")


def maybe_null(value, probability=0.02):
    if random.random() < probability:
        return None
    return value


def messy_coordinate(base_value):
    """
    Create mostly valid coordinates, but sometimes NULL or invalid.
    """
    r = random.random()

    if r < 0.02:
        return None
    elif r < 0.025:
        return 999
    elif r < 0.03:
        return -999
    else:
        return round(base_value + random.uniform(-0.15, 0.15), 6)


def generate_merchants():
    rows = []

    governorates = list(EGYPT_LOCATIONS.keys())

    for i in tqdm(range(1, MERCHANT_COUNT + 1), desc="Generating merchants"):
        raw_merchant_id = f"RAW_M_{i:06d}"
        merchant_id = f"M{i:06d}"

        governorate = random.choice(governorates)
        city = random.choice(EGYPT_LOCATIONS[governorate]["cities"])

        base_lat = EGYPT_LOCATIONS[governorate]["lat"]
        base_lon = EGYPT_LOCATIONS[governorate]["lon"]

        merchant_name = (
            f"{city} "
            f"{random.choice(MERCHANT_NAME_PARTS)} "
            f"{random.randint(1, 999)}"
        )

        onboarding_dt = random_date(datetime(2020, 1, 1), datetime(2025, 12, 31))

        row = {
            "raw_merchant_id": maybe_null(raw_merchant_id, 0.003),
            "merchant_id": maybe_null(merchant_id, 0.002),
            "merchant_name": maybe_null(merchant_name, 0.01),
            "merchant_category": random.choice(MESSY_MERCHANT_CATEGORIES),
            "governorate": maybe_null(governorate, 0.01),
            "city": maybe_null(city, 0.02),
            "latitude": messy_coordinate(base_lat),
            "longitude": messy_coordinate(base_lon),
            "onboarding_ts": messy_timestamp(onboarding_dt),
            "merchant_status": random.choice(["Active", "Suspended", "Closed", "active", "blocked", None]),
            "source_file": "merchants.csv"
        }

        rows.append(row)

    df = pd.DataFrame(rows)

    duplicate_count = max(1, int(MERCHANT_COUNT * 0.01))
    duplicates = df.sample(duplicate_count, random_state=RANDOM_SEED)
    df = pd.concat([df, duplicates], ignore_index=True)

    df = df[RAW_MERCHANTS_COLUMNS]

    output_path = MERCHANTS_DIR / "merchants.csv"
    df.to_csv(output_path, index=False, encoding="utf-8")

    print(f"Generated merchants file: {output_path}")
    print(f"Rows including duplicates: {len(df):,}")
    print("Columns:")
    print(list(df.columns))


if __name__ == "__main__":
    generate_merchants()
