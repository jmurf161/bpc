import mysql.connector

def create_connection(
    host_name: str = "localhost",
    user_name: str = "root",
    password: str = "password",
    database_name: str = "bpc"
):
    """Returns a new MySQL connection using default credentials."""
    return mysql.connector.connect(
        host=host_name,
        user=user_name,
        password=password,
        database=database_name
    )
