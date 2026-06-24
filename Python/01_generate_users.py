import random
from datetime import datetime, timedelta

import numpy as np
import pandas as pd
from faker import Faker
from tqdm import tqdm

from config import (
    USER_COUNT,
    USERS_DIR,
    RAW_USERS_COLUMNS,
    RANDOM_SEED,
    EGYPT_LOCATIONS,
    FIRST_NAMES,
    LAST_NAMES
)

fake = Faker()
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)


def random_date(start_date, end_date):
    days_between = (end_date - start_date).days
    random_days = random.randint(0, days_between)
    return start_date + timedelta(days=random_days)


def messy_timestamp(dt):
    """
    Return timestamp in mixed formats to simulate messy raw data.
    """
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


def generate_phone_number():
    """
    Egyptian-style mobile number.
    Some numbers are intentionally messy.
    """
    prefix = random.choice(["010", "011", "012", "015"])
    number = prefix + "".join(random.choices("0123456789", k=8))

    r = random.random()
    if r < 0.03:
        return None
    elif r < 0.06:
        return "+20" + number[1:]
    elif r < 0.08:
        return number.replace(" ", "")
    else:
        return number


def generate_users():
    rows = []

    governorates = list(EGYPT_LOCATIONS.keys())

    for i in tqdm(range(1, USER_COUNT + 1), desc="Generating users"):
        raw_user_id = f"RAW_U_{i:07d}"
        wallet_id = f"W{i:07d}"

        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        full_name = f"{first_name} {last_name}"

        governorate = random.choice(governorates)
        city = random.choice(EGYPT_LOCATIONS[governorate]["cities"])

        dob = random_date(datetime(1960, 1, 1), datetime(2006, 12, 31))
        signup_dt = random_date(datetime(2022, 1, 1), datetime(2025, 12, 31))

        row = {
            "raw_user_id": maybe_null(raw_user_id, 0.005),
            "wallet_id": maybe_null(wallet_id, 0.002),
            "full_name": maybe_null(full_name, 0.01),
            "phone_number": generate_phone_number(),
            "national_id_last4": maybe_null(str(random.randint(1000, 9999)), 0.04),
            "gender": random.choice(["Male", "Female", "M", "F", None]),
            "date_of_birth": maybe_null(dob.strftime("%Y-%m-%d"), 0.02),
            "governorate": maybe_null(governorate, 0.01),
            "city": maybe_null(city, 0.02),
            "signup_ts": messy_timestamp(signup_dt),
            "kyc_status": random.choice(["Verified", "Pending", "Rejected", "verified", "pending", None]),
            "account_status": random.choice(["Active", "Suspended", "Closed", "active", "blocked"]),
            "source_file": "users.csv"
        }

        rows.append(row)

    df = pd.DataFrame(rows)

    # Add duplicate rows to simulate messy source extracts.
    duplicate_count = max(1, int(USER_COUNT * 0.005))
    duplicates = df.sample(duplicate_count, random_state=RANDOM_SEED)
    df = pd.concat([df, duplicates], ignore_index=True)

    # Make sure column names and order match the staging table contract.
    df = df[RAW_USERS_COLUMNS]

    output_path = USERS_DIR / "users.csv"
    df.to_csv(output_path, index=False, encoding="utf-8")

    print(f"Generated users file: {output_path}")
    print(f"Rows including duplicates: {len(df):,}")
    print("Columns:")
    print(list(df.columns))


if __name__ == "__main__":
    generate_users()
