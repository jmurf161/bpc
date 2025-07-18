import mysql.connector

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="password",
        database="bpc",
        port=3306
    )
    print("✅ Connected successfully.")
    conn.close()
except mysql.connector.Error as err:
    print(f"❌ Connection error: {err}")
