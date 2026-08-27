import pandas as pd
import mysql.connector
from mysql.connector import Error

# Load the CSV file while handling the Byte Order Mark (BOM)
file_path = "C:/DataSet/Image_link.csv"  # Adjust to the path of your uploaded file
df = pd.read_csv(file_path, encoding='utf-8-sig')

# Database connection details
host = 'localhost'  # Replace with your MySQL server hostname
user = 'root'  # Replace with your MySQL username
password = 'abc'  # Replace with your MySQL password
database = 'casestudies'  # Replace with your database name

try:
    # Connect to MySQL database
    connection = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database
    )
    
    if connection.is_connected():
        print("Connected to MySQL database.")
        cursor = connection.cursor()
        
        # Create the table if it does not exist
        create_table_query = """
        CREATE TABLE IF NOT EXISTS image_links (
            work_id INT PRIMARY KEY,
            url TEXT,
            thumbnail_small_url TEXT,
            thumbnail_large_url TEXT
        );
        """
        cursor.execute(create_table_query)
        print("Table 'image_links' created or already exists.")
        
        # Insert data into the table
        for _, row in df.iterrows():
            insert_query = """
            INSERT INTO image_links (work_id, url, thumbnail_small_url, thumbnail_large_url)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                url = VALUES(url),
                thumbnail_small_url = VALUES(thumbnail_small_url),
                thumbnail_large_url = VALUES(thumbnail_large_url);
            """
            cursor.execute(insert_query, (row['work_id'], row['url'], row['thumbnail_small_url'], row['thumbnail_large_url']))
        
        # Commit the transaction
        connection.commit()
        print("Data inserted successfully.")
        
except Error as e:
    print(f"Error: {e}")

finally:
    # Close the connection
    if 'connection' in locals() and connection.is_connected():
        cursor.close()
        connection.close()
        print("MySQL connection is closed.")
