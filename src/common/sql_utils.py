from pathlib import Path

def execute_sql_file(spark, sql_file, display_results=False):
    """
    Execute one or more SQL statements in a .sql file.
    """

    sql_path = Path(sql_file)

    #print(f"\nExecuting SQL file: {sql_path.name}")
    print("hello")
    print("\n======================================")
    print(f"SQL File Provided : {sql_file}")
    print(f"SQL File Resolved : {sql_path.resolve()}")
    print(f"File Exists       : {sql_path.exists()}")
    print("======================================")

    sql_text = sql_path.read_text()

    statements = []

    for stmt in sql_text.split(";"):
        stmt = stmt.strip()

        if stmt:
            statements.append(stmt)

    print(f"Found {len(statements)} SQL statement(s).\n")

    for i, statement in enumerate(statements, start=1):

        print(f"Executing statement {i}/{len(statements)}")

        result = spark.sql(statement)

        if display_results:
            try:
                display(result)
            except NameError:
                result.show(truncate=False)

    print(f"\n✓ Completed: {sql_path.name}")