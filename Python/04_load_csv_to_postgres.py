import csv
import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

from config import (
    USERS_DIR,
    MERCHANTS_DIR,
    TRANSACTIONS_DIR,
    RAW_USERS_COLUMNS,
    RAW_MERCHANTS_COLUMNS,
    RAW_TRANSACTIONS_COLUMNS
)


load_dotenv()


DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "ewallet_fraud"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD")
}


def get_connection():
    """
    Create PostgreSQL connection.
    """
    return psycopg2.connect(**DB_CONFIG)


def check_csv_header(file_path, expected_columns):
    """
    Check that CSV columns match the expected PostgreSQL staging columns.

    This prevents a common mistake:
    CSV column name does not match the table column name.
    """
    with open(file_path, "r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        actual_columns = next(reader)

    if actual_columns != expected_columns:
        print("\nColumn mismatch found!")
        print(f"File: {file_path}")
        print("\nExpected columns:")
        print(expected_columns)
        print("\nActual columns:")
        print(actual_columns)
        raise ValueError("CSV column check failed.")

    print(f"Column check passed: {file_path}")


def copy_csv_to_table(conn, file_path, table_name, columns):
    """
    Load one CSV file into a PostgreSQL table using COPY.

    We pass the column list explicitly so PostgreSQL knows exactly
    which CSV columns go into which table columns.

    staging IDs and loaded_at are not included because PostgreSQL
    creates them automatically.
    """
    column_list = ", ".join(columns)

    copy_sql = f"""
        COPY {table_name} ({column_list})
        FROM STDIN
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            NULL ''
        );
    """

    with conn.cursor() as cur:
        with open(file_path, "r", encoding="utf-8", newline="") as f:
            cur.copy_expert(copy_sql, f)

    conn.commit()
    print(f"Loaded file into {table_name}: {file_path}")


def truncate_staging_tables(conn):
    """
    Clear old staging data before reloading.

    Use this when you are starting a fresh load.
    """
    sql = """
        TRUNCATE TABLE
            staging.raw_users,
            staging.raw_merchants,
            staging.raw_transactions
        RESTART IDENTITY;
    """

    with conn.cursor() as cur:
        cur.execute(sql)

    conn.commit()
    print("Staging tables truncated.")


def analyze_staging_tables(conn):
    """
    Ask PostgreSQL to update table statistics.

    This helps PostgreSQL understand the loaded data better.
    """
    with conn.cursor() as cur:
        cur.execute("ANALYZE staging.raw_users;")
        cur.execute("ANALYZE staging.raw_merchants;")
        cur.execute("ANALYZE staging.raw_transactions;")

    conn.commit()
    print("Staging tables analyzed.")


def count_rows(conn, table_name):
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {table_name};")
        count = cur.fetchone()[0]

    return count


def load_users(conn):
    file_path = USERS_DIR / "users.csv"

    if not file_path.exists():
        raise FileNotFoundError(f"Users file not found: {file_path}")

    check_csv_header(file_path, RAW_USERS_COLUMNS)
    copy_csv_to_table(
        conn=conn,
        file_path=file_path,
        table_name="staging.raw_users",
        columns=RAW_USERS_COLUMNS
    )


def load_merchants(conn):
    file_path = MERCHANTS_DIR / "merchants.csv"

    if not file_path.exists():
        raise FileNotFoundError(f"Merchants file not found: {file_path}")

    check_csv_header(file_path, RAW_MERCHANTS_COLUMNS)
    copy_csv_to_table(
        conn=conn,
        file_path=file_path,
        table_name="staging.raw_merchants",
        columns=RAW_MERCHANTS_COLUMNS
    )


def load_transactions(conn):
    transaction_files = sorted(TRANSACTIONS_DIR.glob("transactions_*.csv"))

    if not transaction_files:
        raise FileNotFoundError(f"No transaction files found in: {TRANSACTIONS_DIR}")

    print(f"Found {len(transaction_files)} transaction files.")

    for file_number, file_path in enumerate(transaction_files, start=1):
        print(f"\nLoading transaction file {file_number}/{len(transaction_files)}")
        check_csv_header(file_path, RAW_TRANSACTIONS_COLUMNS)

        copy_csv_to_table(
            conn=conn,
            file_path=file_path,
            table_name="staging.raw_transactions",
            columns=RAW_TRANSACTIONS_COLUMNS
        )


def print_staging_counts(conn):
    users_count = count_rows(conn, "staging.raw_users")
    merchants_count = count_rows(conn, "staging.raw_merchants")
    transactions_count = count_rows(conn, "staging.raw_transactions")

    print("\nFinal staging row counts:")
    print(f"staging.raw_users:        {users_count:,}")
    print(f"staging.raw_merchants:    {merchants_count:,}")
    print(f"staging.raw_transactions: {transactions_count:,}")


def main():
    conn = get_connection()

    try:
        print("Connected to PostgreSQL.")

        # Use this for a fresh load.
        truncate_staging_tables(conn)

        load_users(conn)
        load_merchants(conn)
        load_transactions(conn)

        analyze_staging_tables(conn)
        print_staging_counts(conn)

        print("\nCSV load finished successfully.")

    except Exception as e:
        conn.rollback()
        print("\nLoad failed.")
        print(e)
        raise

    finally:
        conn.close()
        print("PostgreSQL connection closed.")


if __name__ == "__main__":
    main()
