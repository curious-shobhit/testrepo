#Copy Data
  resource "null_resource" "lakeformationDeRegisterS3CpoyData" {
    depends_on = [aws_s3_bucket.dummy-context-bucket]
    provisioner "local-exec" {
      command =  "aws s3 cp ../modules/lakeformation/loan_payment_clean.csv  s3://dummy-context-bucket-19-05-2019-000000000000000/clean/;sleep 2;aws s3 cp ../modules/lakeformation/loan_payment.csv  s3://dummy-context-bucket-19-05-2019-000000000000000/curated/"
      
    }
  }
#Create S3 Bucket
  resource "aws_s3_bucket" "athena" {
    bucket = "athena-result-demo-0000"
    acl    = "private"
    versioning {
      enabled = true

    }
    tags = {
      Name        = "DummyContextBucket"
      Environment = "Dev"
      Remark      = "Dummy Data"
    }
  }
  resource "aws_s3_bucket_public_access_block" "PublicAccessDemo" {
    bucket = "${aws_s3_bucket.athena.id}"

    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }

#Athena WorkGroup
resource "aws_athena_workgroup" "athena_demo" {
  depends_on = [aws_s3_bucket.athena]
  name = "athena_demo"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://athena-result-demo-0000/"
    }
  }
}
#Athena Bucket Access Policy
resource "aws_iam_policy" "athena_policy" {
  name        = "athena_result_demo"
  path        = "/"
  description = "My test policy"

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::athena-result-demo-0000/*"
    
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "athena_policy" {
    depends_on = [aws_iam_policy.athena_policy]
    role       = "${aws_iam_role.dummy_lake_pii.name}"
    policy_arn = "arn:aws:iam::072496178032:policy/athena_result_demo"
  }
resource "aws_iam_role_policy_attachment" "athena_policy2" {
    depends_on = [aws_iam_policy.athena_policy]
    role       = "${aws_iam_role.dummy_lake_non_pii.name}"
    policy_arn = "arn:aws:iam::072496178032:policy/athena_result_demo"
  }

