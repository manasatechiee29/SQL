import pandas as pd
import mysql.connector
from mysql.connector import Error

# Define MySQL connection details
host = 'localhost'
database = 'casestudies'
user = 'root'
password = 'abc'

# Path to the CSV file
csv_file_path = 'C:/DataSet/Product_size.csv'

# Read the CSV file
data = pd.read_csv(csv_file_path)

# Print the first few rows of the CSV file to verify the data
print("CSV Data Loaded:")
print(data.head())

# Connect to MySQL
try:
    connection = mysql.connector.connect(
        host=host,
        database=database,
        user=user,
        password=password
    )

    if connection.is_connected():
        print("Connected to MySQL server")

        cursor = connection.cursor()

        # Create table if it doesn't exist
        create_table_query = '''
        CREATE TABLE IF NOT EXISTS product_size (
            work_id INT,
            size_id INT,
            sale_price FLOAT,
            regular_price FLOAT,
            PRIMARY KEY (work_id, size_id)
        )
        '''
        cursor.execute(create_table_query)
        print("Table checked/created successfully")

        # Prepare the insert query
        insert_query = '''
        INSERT INTO product_size (work_id, size_id, sale_price, regular_price)
        VALUES (%s, %s, %s, %s)
        '''

        # Insert the data row by row
        for index, row in data.iterrows():
            cursor.execute(insert_query, (row['work_id'], row['size_id'], row['sale_price'], row['regular_price']))

        # Commit the transaction
        connection.commit()
        print(f"Successfully imported {len(data)} rows into the table!")

except Error as e:
    print("Error while connecting to MySQL:", e)

finally:
    # Close the cursor and connection
    if connection.is_connected():
        cursor.close()
        connection.close()
        print("MySQL connection is closed")
