"""
Cleans the raw Superstore CSV so it loads easily into MySQL.

- Fixes the broken first column name (byte-order mark + stray text)
- Converts dates from DD-MM-YYYY to YYYY-MM-DD
- Drops the empty helper columns (ind1, ind2)
- Renames columns to snake_case

Run:  python python/clean_data.py
"""
from pathlib import Path

import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data"

df = pd.read_csv(DATA / "SuperStore_Sales_Dataset.csv", encoding="latin1")
df = df.rename(columns={df.columns[0]: "Row ID"}).drop(columns=["ind1", "ind2"], errors="ignore")
for col in ["Order Date", "Ship Date"]:
    df[col] = pd.to_datetime(df[col], format="%d-%m-%Y").dt.strftime("%Y-%m-%d")
df.columns = [c.strip().lower().replace(" ", "_").replace("-", "_") for c in df.columns]
df["returns"] = df["returns"].notna().map({True: "Yes", False: "No"})  # 1 = returned

df.to_csv(DATA / "superstore_clean.csv", index=False)
print(f"Saved {len(df):,} rows, {df['order_id'].nunique():,} orders -> data/superstore_clean.csv")
print("Columns:", ", ".join(df.columns))
