# used to test vscode connectivity

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, StringType

schema = StructType([
    StructField("id", StringType(), True),
    StructField("name", StringType(), True),
    StructField("age", IntegerType(), True),

]
)
spark = SparkSession.builder.appName("TestApp").getOrCreate()

data = [
    ("code1", "Alice", 30),
    ("code2", "Bob", 25),
    ("code3", "Charlie", 35),    
]


df = spark.createDataFrame(data, schema)
df.show()