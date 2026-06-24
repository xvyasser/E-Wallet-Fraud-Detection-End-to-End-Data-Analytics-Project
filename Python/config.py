from pathlib import Path

# -----------------------------
# Project paths
# -----------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = PROJECT_ROOT / "data" / "generated"
USERS_DIR = DATA_DIR / "users"
MERCHANTS_DIR = DATA_DIR / "merchants"
TRANSACTIONS_DIR = DATA_DIR / "transactions"

USERS_DIR.mkdir(parents=True, exist_ok=True)
MERCHANTS_DIR.mkdir(parents=True, exist_ok=True)
TRANSACTIONS_DIR.mkdir(parents=True, exist_ok=True)

# -----------------------------
# Dataset size
# -----------------------------
# Start with sample mode first.
# Do not start with 50M transactions immediately.

RUN_MODE = "full"  # change to "full" later

if RUN_MODE == "sample":
    USER_COUNT = 10_000
    MERCHANT_COUNT = 1_000
    TRANSACTION_COUNT = 100_000
    TRANSACTION_CHUNK_SIZE = 25_000
else:
    USER_COUNT = 500_000
    MERCHANT_COUNT = 15_000
    TRANSACTION_COUNT = 50_000_000
    TRANSACTION_CHUNK_SIZE = 500_000

RANDOM_SEED = 42

# -----------------------------
# CSV column contracts
# These must match PostgreSQL staging table columns.
# We exclude BIGSERIAL IDs and loaded_at because PostgreSQL handles them.
# -----------------------------

RAW_USERS_COLUMNS = [
    "raw_user_id",
    "wallet_id",
    "full_name",
    "phone_number",
    "national_id_last4",
    "gender",
    "date_of_birth",
    "governorate",
    "city",
    "signup_ts",
    "kyc_status",
    "account_status",
    "source_file"
]

RAW_MERCHANTS_COLUMNS = [
    "raw_merchant_id",
    "merchant_id",
    "merchant_name",
    "merchant_category",
    "governorate",
    "city",
    "latitude",
    "longitude",
    "onboarding_ts",
    "merchant_status",
    "source_file"
]

RAW_TRANSACTIONS_COLUMNS = [
    "raw_transaction_id",
    "transaction_id",
    "sender_wallet_id",
    "receiver_wallet_id",
    "merchant_id",
    "transaction_type",
    "transaction_status",
    "transaction_amount",
    "currency",
    "transaction_ts",
    "latitude",
    "longitude",
    "device_id",
    "channel",
    "is_fraud_injected",
    "fraud_pattern",
    "source_file"
]

# -----------------------------
# Egyptian geography sample
# -----------------------------

EGYPT_LOCATIONS = {
    "Cairo": {
        "cities": ["Nasr City", "Heliopolis", "Maadi", "Shubra", "New Cairo"],
        "lat": 30.0444,
        "lon": 31.2357
    },
    "Giza": {
        "cities": ["Dokki", "Mohandessin", "Haram", "6th of October", "Sheikh Zayed"],
        "lat": 30.0131,
        "lon": 31.2089
    },
    "Alexandria": {
        "cities": ["Sidi Gaber", "Smouha", "Miami", "Stanley", "Mandara"],
        "lat": 31.2001,
        "lon": 29.9187
    },
    "Dakahlia": {
        "cities": ["Mansoura", "Talkha", "Mit Ghamr", "Aga", "Belqas"],
        "lat": 31.0409,
        "lon": 31.3785
    },
    "Sharkia": {
        "cities": ["Zagazig", "10th of Ramadan", "Belbeis", "Minya El Qamh"],
        "lat": 30.7327,
        "lon": 31.7195
    },
    "Gharbia": {
        "cities": ["Tanta", "El Mahalla", "Kafr El Zayat", "Zefta"],
        "lat": 30.8754,
        "lon": 31.0335
    },
    "Aswan": {
        "cities": ["Aswan City", "Kom Ombo", "Edfu"],
        "lat": 24.0889,
        "lon": 32.8998
    },
    "Luxor": {
        "cities": ["Luxor City", "Esna", "Armant"],
        "lat": 25.6872,
        "lon": 32.6396
    },
    "Red Sea": {
        "cities": ["Hurghada", "Safaga", "Marsa Alam"],
        "lat": 27.2579,
        "lon": 33.8116
    },
    "Port Said": {
        "cities": ["Port Said City", "Port Fouad"],
        "lat": 31.2653,
        "lon": 32.3019
    }
}

FIRST_NAMES = [
    "Ahmed", "Mohamed", "Mahmoud", "Mostafa", "Omar", "Youssef", "Ali",
    "Mona", "Sara", "Nour", "Aya", "Heba", "Fatma", "Yasmin", "Dina"
]

LAST_NAMES = [
    "Hassan", "Ali", "Mahmoud", "Ibrahim", "Sayed", "Fathy", "Gamal",
    "Abdelrahman", "Samir", "Yasser", "Farouk", "Nasser"
]

MERCHANT_NAME_PARTS = [
    "Market", "Store", "Pharmacy", "Mobile", "Cafe", "Restaurant",
    "Fashion", "Electronics", "Supermarket", "Bakery", "Kiosk"
]

MESSY_MERCHANT_CATEGORIES = [
    "food", "Food", "FOOD", "restaurant", "restaurants", "F&B",
    "grocery", "Groceries", "supermarket",
    "mobile topup", "topup", "airtime",
    "bills", "electricity", "water", "gas",
    "electronics", "Electronics", "mobile shop",
    "fashion", "clothes", "apparel",
    "transport", "ride hailing", "bus",
    "education", "courses",
    "healthcare", "pharmacy",
    "unknown"
]

TRANSACTION_TYPES = [
    "P2P", "wallet_transfer", "transfer",
    "CASH_IN", "cashin", "deposit",
    "CASH_OUT", "cashout", "withdrawal",
    "MERCHANT_PAYMENT", "merchant", "payment",
    "BILL_PAYMENT", "bill", "utility",
    "TOPUP", "airtime", "mobile_topup"
]

TRANSACTION_STATUSES = [
    "SUCCESS", "success", "succeeded", "done", "Completed",
    "FAILED", "failed", "fail", "declined", "rejected",
    "PENDING", "pending",
    "REVERSED", "reversed", "refund"
]

CHANNELS = [
    "mobile_app",
    "ussd",
    "agent",
    "merchant_qr",
    "web"
]