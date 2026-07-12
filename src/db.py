import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def get_engine():
    load_dotenv()  # Load environment variables from .env file
    database_url = os.getenv("DATABASE_URL")  # Get the database URL from environment variables
    if database_url is None or database_url.strip() == "":
        raise ValueError("DATABASE_URL environment variable is not set.")
    else:
        print("DATABASE_URL is set.")
    engine = create_engine(database_url, echo=True)
    return engine  # Create a SQLAlchemy engine with the database URL

def connection_test():
    try:
        engine = get_engine()  # Get the SQLAlchemy engine
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))  # Execute a simple query to test the connection
            print("Database connection successful:", result.scalar())  # Print the result of the query
    except Exception as e:
        print("Database connection failed:", str(e))  # Print an error message if the connection fails

if __name__ == "__main__":
    connection_test()  # Run the connection test if this script is executed directly