variable "s3_bucket_domain" {
  description = "Domain name for Database"
  default = "loan"
}

variable "bucket_id" {
  description = "Newly Created Bucket Name "
  default     = "dummy-context-bucket-19-05-2019-000000000000000"
}

variable "database_description" {
  description = "Description for database"
  default     = "Database for loan domain"
}