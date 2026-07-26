from pathlib import Path

def execute_sql_file(spark, sql_file, display_results=False):
    
    # Execute one or more SQL statements in a .sql file.

    sql_path = Path(sql_file)

    print(f"\nExecuting SQL file: {sql_path.name}")

    sql_text = sql_path.read_text()

    # Create an array of SQL statements
    statements = []

    for stmt in sql_text.split(";"):
        stmt = stmt.strip()

        if stmt:
            statements.append(stmt)

    print(f"Found {len(statements)} SQL statement(s).\n")

    # Execute each SQL statement in the array.
    for i, statement in enumerate(statements, start=1):

        print(f"Executing statement {i}/{len(statements)}")

        result = spark.sql(statement) # execute the statement

        # Display the results.  display() is a databricks function
        if display_results:
            try:
                display(result)
            except NameError:
                result.show(truncate=False)

    print(f"\n✓ Completed: {sql_path.name}")





#from pathlib import Path

#def execute_sql_file(spark, sql_file):
 #   """
 #   Execute one or more SQL statements from a .sql file.

    #Parameters
   # ----------
    #spark : SparkSession
    #    Active Spark session.

    #sql_file : str
    #    Path to the SQL file.
    #"""

    #sql_text = Path(sql_file).read_text()

    #statements = sql_text.split(";")

    #for statement in statements:
    #    statement = statement.strip()
#
 #       if statement:
  #          spark.sql(statement)