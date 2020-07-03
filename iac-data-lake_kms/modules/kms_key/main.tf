resource "aws_kms_key" "data_kms_key" {
  description             = var.kms_key_alias
  enable_key_rotation  = "true"
  policy = <<-EOF
 {
    "Id": "data_kms_key",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.root_user}"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.key_admin}"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        }
        
    
    ]
}
EOF
tags = var.kms_key_tags

}
resource "aws_kms_alias" "data_kms_key_alias" {
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.data_kms_key.key_id
}


