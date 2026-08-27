import mysql.connector
import csv

# Database connection configuration
db_config = {
    'host': 'localhost',  # Change to your MySQL host
    'user': 'root',       # Change to your MySQL username
    'password': 'abc',  # Change to your MySQL password
    'database': 'casestudies'  # Change to your database name
}

# Establish a database connection
try:
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    # Create table if it doesn't exist
    create_table_query = """
    CREATE TABLE IF NOT EXISTS museum (
        museum_id INT PRIMARY KEY,
        name VARCHAR(255),
        address VARCHAR(255),
        city VARCHAR(100),
        state VARCHAR(100),
        postal VARCHAR(20),
        country VARCHAR(100),
        phone VARCHAR(50),
        url VARCHAR(255)
    );
    """
    cursor.execute(create_table_query)
    print("Table 'museums' created or already exists.")

    # File path to the CSV
    csv_file_path = 'C:/DataSet/museum.csv'  # Replace with the path to your CSV file

    # Read and insert CSV data into the table
    with open(csv_file_path, mode='r', encoding='utf-8') as file:
        csv_reader = csv.DictReader(file)
        insert_query = """
        INSERT INTO museums (museum_id, name, address, city, state, postal, country, phone, url)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            address = VALUES(address),
            city = VALUES(city),
            state = VALUES(state),
            postal = VALUES(postal),
            country = VALUES(country),
            phone = VALUES(phone),
            url = VALUES(url);
        """
        for row in csv_reader:
            data = (
                int(row['museum_id']),
                row['name'],
                row['address'],
                row['city'],
                row['state'] if row['state'] else None,
                row['postal'],
                row['country'],
                row['phone'],
                row['url']
            )
            cursor.execute(insert_query, data)

    # Commit the transaction
    conn.commit()
    print("Data imported successfully.")

except mysql.connector.Error as err:
    print(f"Error: {err}")

finally:
    if conn.is_connected():
        cursor.close()
        conn.close()
        print("Database connection closed.")
