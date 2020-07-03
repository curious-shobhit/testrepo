#Create Database  
  resource "aws_glue_catalog_database" "ContextDatabase" {
    name = "lake-${var.s3_bucket_domain}-db"
    location_uri = "s3://${var.bucket_id}"
    description  = var.database_description
    }