"""
Ingest Excel (.xls) data into Azure PostgreSQL Database
"""
import os
import pandas as pd
import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_values
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Database connection settings
DB_CONFIG = {
    "host": os.getenv("AZURE_PG_HOST"),         # e.g., "yourserver.postgres.database.azure.com"
    "database": os.getenv("AZURE_PG_DATABASE"), # e.g., "your_database"
    "user": os.getenv("AZURE_PG_USER"),         # e.g., "username@yourserver"
    "password": os.getenv("AZURE_PG_PASSWORD"),
    "port": os.getenv("AZURE_PG_PORT", "5432"),
    "sslmode": "require"  # Azure requires SSL
}

# Excel file paths and their target tables
DATA_DIR = os.path.join(os.path.dirname(__file__), "Data")

EXCEL_TABLE_MAPPING = {
    "Orders.xls": {
        "table": "stg.orders",
        "date_columns": ["order_date", "ship_date"]
    },
    "People.xls": {
        "table": "stg.people",
        "date_columns": []
    },
    "Returns.xls": {
        "table": "stg.returns",
        "date_columns": []
    }
}


def get_connection():
    """Create database connection."""
    return psycopg2.connect(**DB_CONFIG)


def create_schema_if_not_exists(conn):
    """Ensure the stg schema exists."""
    with conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS stg;")
    conn.commit()
    print("Schema 'stg' ready.")


def truncate_table(conn, table_name):
    """Truncate table before loading."""
    with conn.cursor() as cur:
        cur.execute(sql.SQL("TRUNCATE TABLE {} CASCADE;").format(
            sql.Identifier(*table_name.split("."))
        ))
    conn.commit()
    print(f"Truncated {table_name}")


def load_excel_to_table(conn, excel_path, table_config):
    """Load an Excel file into the specified table."""
    table_name = table_config["table"]
    date_columns = table_config["date_columns"]

    # Read Excel file (.xls format requires xlrd)
    df = pd.read_excel(excel_path, engine="xlrd")

    # Clean column names (lowercase, replace spaces/slashes with underscores)
    df.columns = [col.lower().replace(" ", "_").replace("-", "_").replace("/", "_") for col in df.columns]

    # Convert date columns to date objects
    for col in date_columns:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col]).dt.date

    print(f"Loaded {len(df)} rows from {os.path.basename(excel_path)}")

    # Truncate existing data
    truncate_table(conn, table_name)

    # Insert data using batch insert (much faster)
    columns = df.columns.tolist()

    # Prepare data - convert NaN to None
    data = [
        tuple(None if pd.isna(v) else v for v in row)
        for _, row in df.iterrows()
    ]

    # Build INSERT query
    schema, table = table_name.split(".")
    col_names = ", ".join(f'"{c}"' for c in columns)
    insert_query = f'INSERT INTO "{schema}"."{table}" ({col_names}) VALUES %s'

    # Batch insert
    with conn.cursor() as cur:
        execute_values(cur, insert_query, data, page_size=1000)

    conn.commit()
    print(f"Inserted {len(df)} rows into {table_name}")


def main():
    """Main function to orchestrate data ingestion."""
    # Validate config
    missing = [k for k, v in DB_CONFIG.items() if v is None and k != "port"]
    if missing:
        print(f"Missing environment variables: {missing}")
        print("\nCreate a .env file with:")
        print("  AZURE_PG_HOST=yourserver.postgres.database.azure.com")
        print("  AZURE_PG_DATABASE=your_database")
        print("  AZURE_PG_USER=username@yourserver")
        print("  AZURE_PG_PASSWORD=your_password")
        return

    try:
        conn = get_connection()
        print("Connected to Azure PostgreSQL")

        # Ensure schema exists
        create_schema_if_not_exists(conn)

        # Load each Excel file
        for excel_file, table_config in EXCEL_TABLE_MAPPING.items():
            excel_path = os.path.join(DATA_DIR, excel_file)

            if not os.path.exists(excel_path):
                print(f"Warning: {excel_path} not found, skipping.")
                continue

            load_excel_to_table(conn, excel_path, table_config)

        print("\nData ingestion complete!")

    except Exception as e:
        print(f"Error: {e}")
        raise
    finally:
        if 'conn' in locals():
            conn.close()
            print("Connection closed.")


if __name__ == "__main__":
    main()
