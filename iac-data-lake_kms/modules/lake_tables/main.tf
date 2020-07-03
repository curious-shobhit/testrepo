resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = var.tab_name
  database_name = var.context_databaset_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://my-bucket/event-streams/my-stream"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }
    dynamic columns  {
      for_each = [for s in var.tab_cols: {
      name      = split(":",s[0])[1]
      type      = split(":",s[1])[1]
      comment   = split(":",s[2])[1]   
      }]
      content {
                name = columns.name.value
                type = columns.type.value
                comment = columns.comments.value
              }   
      }   
    }
    
  }
