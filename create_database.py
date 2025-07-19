import mysql.connector
import sqlparse
import sys


conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password"
)

cursor = conn.cursor()

sql_files = [
    'schema/create_database.sql',
    'schema/create_tables.sql',
    'logic/procedures/department.sql',
    'logic/procedures/feature.sql',
    'logic/procedures/material.sql',
    'logic/procedures/order.sql',
    'logic/procedures/release.sql',
    'logic/procedures/sub_feature.sql',
    'logic/triggers/triggers.sql',
    'logic/functions/functions.sql'
    #'seed/insert_data.sql'
]


# Execute each file safely
for file in sql_files:
    try:
        with open(file, 'r') as f:
            sql_script = f.read()

            # Split while respecting multi-line statements
            commands = sqlparse.split(sql_script)

            for command in commands:
                command = command.strip()
                if command:
                    try:
                        cursor.execute(command)
                    except mysql.connector.Error as err:
                        print(f"\nError in file: {file}")
                        print(f"Command: {command}")
                        print(f"MySQL Error: {err}\n")
        #print(f'{file} added to database.')
    except FileNotFoundError:
        print(f"File not found: {file}")

print("~~~ Database Created ~~~")

# Finalize
conn.commit()
cursor.close()
conn.close()


