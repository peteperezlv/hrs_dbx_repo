from pathlib import Path

def execute_sql_file(spark, sql_file):
    """
    Execute one or more SQL statements from a .sql file.

    Parameters
    ----------
    spark : SparkSession
        Active Spark session.

    sql_file : str
        Path to the SQL file.
    """

    sql_text = Path(sql_file).read_text()

    statements = sql_text.split(";")

    for statement in statements:
        statement = statement.strip()

        if statement:
            spark.sql(statement)