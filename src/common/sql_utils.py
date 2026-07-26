#This python app provides a common funtion that can be used to execute multi-SQL-statement files.

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

def execute_sql_file(spark, sql_file, display_results=False):
    """
    Execute one or more SQL statements in a .sql file.
    """

    # Step 1 - Set the sql path variable and check if it exists.
    sql_path = Path(sql_file)

    print("\n======================================")
    print(f"Executing SQL file: {sql_path.name}")
    print("======================================")

    if not sql_path.exists():
        raise FileNotFoundError(
            f"SQL file not found: {sql_path.resolve()}"
    )

    # Step 2 - Read the SQL file statements and create an array of SQL statements.
    sql_text = sql_path.read_text()

    statements = []

    for stmt in sql_text.split(";"):
        stmt = stmt.strip()

        if stmt:
            statements.append(stmt)

    print(f"Found {len(statements)} SQL statement(s).\n")

    # Step 3 - Use the enumerate function to loop throgh each SQL statement and execute it.
    for i, statement in enumerate(statements, start=1):

        print(f"\nExecuting statement {i}/{len(statements)}")

        result = spark.sql(statement)

        if display_results:
            try:
                display(result)
            except NameError:
                result.show(truncate=False)

    print(f"\n✓ Completed: {sql_path.name}")