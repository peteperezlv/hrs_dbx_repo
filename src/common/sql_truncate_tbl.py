#**Purpose: 
    # Handle .sql files with multiple SQL statements.

#**Function Name: 
    # execute_sql_file

#**Function Arguments**
    #  spark - The active SparkSession.
    #  sql_file - The name of the .sql file with one or more SQL statements.
    #  display_results - True or False to direct the function how to handle the 'display' statement

#**Process:**
    # Step 1 - Set the sql path variable and check if it exists.
    # Step 2 - Read the SQL file statements and create an array of SQL statements.
    # Step 3 - Use the enumerate function to loop throgh each SQL statement and execute it.

from pathlib import Path

def execute_sql_file(spark, target_table, display_results=False):

# Step 1 - Set the sql path variable and check if it exists.
    tbl_path = Path(target_table)

    if not tbl_path.exists():
            raise FileNotFoundError(
                f"SQL file not found: {tbl_path.resolve()}"
        )

    print("======================================================")
    print("TRUNCATE TABLE")
    print("======================================================")
    if tbl_path:
        try:
            spark.sql(f"TRUNCATE TABLE {tbl_path}")
            print("✓ Completed")
        except Exception as e:
            print(f"An unexpected error occured: {e}");


