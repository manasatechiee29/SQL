import mysql.connector
import csv

# MySQL connection details
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "abc",  # Replace with your MySQL password
    "database": "casestudies"     # Replace with your database name
}

# Table name
table_name = "work"

# Path to the CSV file
csv_file = "C:/DataSet/work.csv"

# Function to replace null/empty values with None
def replace_nulls(row):
    return [None if val == "" else val for val in row]

# Establish connection to MySQL
try:
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()

    # Create table if it doesn't exist
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS {table_name} (
        work_id INT,
        name VARCHAR(255),
        artist_id INT,
        style VARCHAR(100),
        museum_id INT
    );
    """
    cursor.execute(create_table_query)

    # Read CSV file and insert data
    with open(csv_file, mode='r', encoding='utf-8') as file:
        csv_reader = csv.reader(file)
        next(csv_reader)  # Skip the header row
        
        insert_query = f"""
        INSERT INTO {table_name} (work_id, name, artist_id, style, museum_id)
        VALUES (%s, %s, %s, %s, %s)
        """
        for row in csv_reader:
            cleaned_row = replace_nulls(row)  # Replace null/empty values
            cursor.execute(insert_query, cleaned_row)
    
    # Commit changes
    connection.commit()
    print("Data imported successfully!")

except mysql.connector.Error as e:
    print(f"Error: {e}")

finally:
    # Close connection
    if connection.is_connected():
        cursor.close()
        connection.close()
