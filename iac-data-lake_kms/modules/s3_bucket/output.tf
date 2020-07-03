output "context_bucket" {
  description = "Newly Created Bucket Name "
  value = aws_s3_bucket.context_bucket.id
}
output "context_bucket_arn" {
  description = "Newly Created Bucket arn "
  value = aws_s3_bucket.context_bucket.arn
}