output "database_name" {
  description = "Newly Database Name"
  value = aws_glue_catalog_database.ContextDatabase.name
}