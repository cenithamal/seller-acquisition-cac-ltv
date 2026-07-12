from db import get_engine
import pandas as pd

def load_raw_tables():
    """
    Load raw tables from CSV files into the database.

    This function reads raw data from CSV files and loads them into the database
    using SQLAlchemy. The tables are created or replaced in the database.

    Returns:
        None
    """
    orders = pd.read_csv("data/raw/ecommerce_data/olist_orders_dataset.csv")
    customers = pd.read_csv("data/raw/ecommerce_data/olist_customers_dataset.csv")
    order_items = pd.read_csv("data/raw/ecommerce_data/olist_order_items_dataset.csv")
    payments = pd.read_csv("data/raw/ecommerce_data/olist_order_payments_dataset.csv")
    leads = pd.read_csv("data/raw/marketing_funnel_data/olist_marketing_qualified_leads_dataset.csv")
    deals = pd.read_csv("data/raw/marketing_funnel_data/olist_closed_deals_dataset.csv")

    engine = get_engine()

    tables = {
        "raw_order": orders,
        "raw_customer": customers,
        "raw_order_item": order_items,
        "raw_payment": payments,
        "raw_lead": leads,
        "raw_deal": deals
    }

    for table_name, data_frame in tables.items():
        print(f"Writing {table_name} to database...")
        data_frame.to_sql(table_name, engine, if_exists='replace', index=False)
        print(f"Finished writing {table_name}: {data_frame.shape[0]} rows to database.")

if __name__ == "__main__":
    load_raw_tables()