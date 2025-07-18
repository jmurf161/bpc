import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password"
)

cursor = conn.cursor()
cursor.execute("ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';")
cursor.execute("FLUSH PRIVILEGES;")

conn.commit()
cursor.close()
conn.close()