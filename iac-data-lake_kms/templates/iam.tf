resource "aws_iam_policy" "prj_phk_lake_data_ingestion" {
  name        = "lake_data_ingestion"
  path        = "/"
  description = "Data Ingestion to raw zone of s3"

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",                
                "s3:PutObjectTagging"
            ],
            "Resource":"arn:aws:s3:::phx-poc-loan-sg/raw/*"          
            
        }
    ]
}
 EOF
}
resource "aws_iam_role" "lake_ingestion_role" {
    name = "lake_ingestionn_role"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    tags = {
      Name        = "Lake Ingestion User"
      Project     = "Phoenix"
    }
  }
  resource "aws_iam_role_policy_attachment" "policy_attach" {
    role       = aws_iam_role.lake_ingestion_role.name
    policy_arn = aws_iam_policy.prj_phk_lake_data_ingestion.arn
  }