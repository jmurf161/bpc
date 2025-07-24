import mysql.connector

def test_mysql_fetch():
    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="password",
        database="bpc"
    )
    print("Connected to DB:", db.database)
    cursor = db.cursor()

    try:
        cursor.execute("SHOW COLUMNS FROM departments")
        columns = cursor.fetchall()
        print("Columns:", columns)

        cursor.execute("SELECT * FROM departments")
        rows = cursor.fetchall()
        print(f"Fetched {len(rows)} rows")

    except Exception as e:
        print("❌ ERROR:", e)

    cursor.close()
    db.close()

if __name__ == "__main__":
    test_mysql_fetch()