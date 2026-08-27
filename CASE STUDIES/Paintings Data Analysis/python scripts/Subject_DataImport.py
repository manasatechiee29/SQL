import csv
import mysql.connector

# MySQL configuration
db_config = {
    "host": "localhost",  # Replace with your MySQL server hostname
    "user": "root",       # Replace with your MySQL username
    "password": "abc",  # Replace with your MySQL password
    "database": "casestudies"  # Replace with your MySQL database name
}

# CSV file path
csv_file = "C:/DataSet/subject.csv"  # Update with the actual path to your CSV file

# Connect to the MySQL server
try:
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()

    # Create table if not exists
    create_table_query = """
    CREATE TABLE IF NOT EXISTS subject (
        work_id INT NOT NULL,
        subject VARCHAR(255) NOT NULL
    );
    """
    cursor.execute(create_table_query)

    # Read and insert data from CSV
    with open(csv_file, mode="r") as file:
        csv_data = csv.reader(file)
        next(csv_data)  # Skip header row
        
        insert_query = "INSERT INTO subject (work_id, subject) VALUES (%s, %s)"
        for row in csv_data:
            cursor.execute(insert_query, row)

    # Commit the transaction
    connection.commit()
    print("Data imported successfully!")

except mysql.connector.Error as err:
    print(f"Error: {err}")

finally:
    # Close the connection
    if connection.is_connected():
        cursor.close()
        connection.close()
        print("MySQL connection closed.")
