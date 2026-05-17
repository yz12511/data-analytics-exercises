"""
Full Data Warehouse ETL Pipeline
---------------------------------
Three-layer medallion architecture:

  [Group 1] Load Raw      → bronze schema  (CSV files → Postgres tables)
  [Group 2] Silver Layer   → silver schema  (dbt staging + silver models)
  [Group 3] Gold Layer     → gold schema    (dbt star schema: dims + fact)

Drop CSV files into ./data/raw/ and trigger this DAG manually or @daily.

Exercises 3–13 ask you to implement the functions below step by step.
"""

import os
import csv
import glob
import psycopg2
import requests
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

# ---------------------------------------------------------------------------
# Connection config — reads from Docker environment variables (do not change)
# ---------------------------------------------------------------------------

DB_CONN = {
    "host":     os.environ["ANALYTICS_DB_HOST"],
    "dbname":   os.environ["ANALYTICS_DB_NAME"],
    "user":     os.environ["ANALYTICS_DB_USER"],
    "password": os.environ["ANALYTICS_DB_PASSWORD"],
}
DBT_BASE = "http://dbt:8087"


# ---------------------------------------------------------------------------
# Helper functions — Exercise 3
# ---------------------------------------------------------------------------

def _load_csv(table, csv_path, columns):
    """Load a CSV file into a bronze PostgreSQL table as TEXT columns."""
    files = glob.glob(csv_path)
    if not files:
        raise FileNotFoundError(f"No files found for path: {csv_path}")

    conn = psycopg2.connect(**DB_CONN)
    cur = conn.cursor()

    cur.execute("CREATE SCHEMA IF NOT EXISTS bronze;")

    cols_sql = ", ".join([f"{col} TEXT" for col in columns])
    cur.execute(f"CREATE TABLE IF NOT EXISTS bronze.{table} ({cols_sql});")
    cur.execute(f"TRUNCATE TABLE bronze.{table};")

    placeholders = ", ".join(["%s"] * len(columns))
    cols_insert = ", ".join(columns)
    insert_sql = f"INSERT INTO bronze.{table} ({cols_insert}) VALUES ({placeholders})"

    total_rows = 0

    for file in files:
        with open(file, newline="", encoding="utf-8-sig") as f:
            reader = csv.DictReader(f)
            rows = [tuple(row.get(col) for col in columns) for row in reader]

        if rows:
            cur.executemany(insert_sql, rows)
            total_rows += len(rows)

    conn.commit()
    cur.close()
    conn.close()

    print(f"Loaded {total_rows} rows into bronze.{table}")

def _call_dbt(endpoint: str):
    """
    POST to a dbt server endpoint and raise on failure.

    Steps to implement:
      1. POST to f"{DBT_BASE}/{endpoint}" with a 300s timeout.
      2. Parse the JSON response.
      3. Print result["output"].
      4. If result["returncode"] != 0, raise an Exception.
    """
    response = requests.post(f"{DBT_BASE}/{endpoint}", timeout=300)

    try:
        result = response.json()
    except ValueError as exc:
        response.raise_for_status()
        raise Exception(f"dbt endpoint {endpoint!r} returned invalid JSON") from exc

    output = result.get("output", "")
    print(output)

    if result.get("returncode") != 0:
        raise Exception(f"dbt endpoint {endpoint!r} failed:\n{output}")

    response.raise_for_status()


# ---------------------------------------------------------------------------
# Task functions — Group 1: Load Raw   (Exercises 3–5)
# ---------------------------------------------------------------------------

def load_regions():
    """Load data/raw/regions.csv into bronze.regions."""
    _load_csv(
        table="regions",
        csv_path="/opt/data/raw/regions.csv",
        columns=["region_id", "region_name", "country", "continent"],
    )


def load_clients():
    """Load data/raw/clients.csv into bronze.clients."""
    _load_csv(
        table="clients",
        csv_path="/opt/data/raw/clients.csv",
        columns=["client_id", "client_name", "client_type", "region_id", "email"],
    )


def load_products():
    """Load data/raw/products.csv into bronze.products."""
    _load_csv(
        table="products",
        csv_path="/opt/data/raw/products.csv",
        columns=["product_id", "product_name", "category", "subcategory", "list_price"],
    )


def load_orders():
    """Load data/raw/orders.csv into bronze.orders."""
    _load_csv(
        table="orders",
        csv_path="/opt/data/raw/orders.csv",
        columns=[
            "order_id",
            "order_date",
            "client_id",
            "product_id",
            "quantity",
            "unit_price",
            "discount_pct",
        ],
    )

# ---------------------------------------------------------------------------
# Task functions — Group 2: CDW Core   (Exercises 6–11)
# ---------------------------------------------------------------------------

def run_dbt_staging():
    """Exercise 6: trigger dbt staging models via the HTTP server"""
    _call_dbt("run/staging")


def run_dbt_silver():
    """Exercise 9: trigger dbt core models via the HTTP server"""
    _call_dbt("run/silver")


# ---------------------------------------------------------------------------
# Task functions — Group 3: Data Mart  (Exercises 12–13)
# ---------------------------------------------------------------------------

def run_dbt_gold():
    """Exercise 12: trigger dbt mart models via the HTTP server"""
    _call_dbt("run/gold")


# ---------------------------------------------------------------------------
# DAG definition — do not modify this section
# ---------------------------------------------------------------------------

with DAG(
    dag_id="etl_full_pipeline",
    description="CSV → bronze → Bronze → Silver → Gold Star Schema",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    with TaskGroup("load_raw") as load_raw:
        t_regions  = PythonOperator(task_id="load_regions",  python_callable=load_regions)
        t_clients  = PythonOperator(task_id="load_clients",  python_callable=load_clients)
        t_products = PythonOperator(task_id="load_products", python_callable=load_products)
        t_orders   = PythonOperator(task_id="load_orders",   python_callable=load_orders)

    with TaskGroup("silver") as silver:
        t_staging = PythonOperator(task_id="run_dbt_staging", python_callable=run_dbt_staging)
        t_core    = PythonOperator(task_id="run_dbt_silver",    python_callable=run_dbt_silver)
        t_staging >> t_core

    with TaskGroup("gold") as gold:
        t_mart = PythonOperator(task_id="run_dbt_gold", python_callable=run_dbt_gold)

    load_raw >> silver >> gold
