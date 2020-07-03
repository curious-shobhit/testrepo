output "kms_key_id" {
  description = "Newly Created Key ID"
  value = aws_kms_key.data_kms_key.key_id
}
output "kms_key_alias" {
  description = "Newly Created Key ID"
  value = aws_kms_alias.data_kms_key_alias.name
}