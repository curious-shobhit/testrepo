locals {
  product = "${setproduct(var.s3_zones, var.s3_zones_dataset)}"
  # Common tags to be assigned to s3
  common_tags = {Domain = var.s3_bucket_domain}
}  

data "aws_kms_key" "data_kms_key" {
  key_id = var.kms_grant_key_alias
}

#Create S3 Bucket
  resource "aws_s3_bucket" "context_bucket" {
    bucket = "${var.s3_bucket_name_project}-${var.s3_bucket_name_env}-${var.s3_bucket_domain}-${var.s3_bucket_name_region}"
    acl    = "private"
    #Bucket Version enabled
    versioning {
      enabled = true
    }
    # Rule - previous version of file to move other s3 tier
     dynamic lifecycle_rule {
      for_each = [for s in var.prv_trans: {
      prefix  = s[0]
      enabled = s[1]
      days          = s[3]   
      storage_class = s[2]
      }]
      content {
      prefix = lifecycle_rule.value.prefix
      enabled = tobool(lifecycle_rule.value.enabled)
      noncurrent_version_transition {
        days   = lifecycle_rule.value.days
        storage_class = lifecycle_rule.value.storage_class
      }   
      }   
    }
    # Rule - current version of file to move other s3 tier
    dynamic lifecycle_rule {
      for_each = [for s in var.trans: {
      prefix  = s[0]
      enabled = s[1]
      days          = s[3]  
      storage_class = s[2]
     
      }]
      content {
      prefix = lifecycle_rule.value.prefix
      enabled = tobool(lifecycle_rule.value.enabled)
      transition {
        days   = lifecycle_rule.value.days
        storage_class = lifecycle_rule.value.storage_class
      }    
      }   
    }
    # Rule for previous version file deletion
     dynamic lifecycle_rule {
      for_each = [for s in var.prv_trans_del: {
        prefix  = s[0]
        enabled  = s[1]  
        expr_days     = s[2]  
      }]
      content {
      prefix = lifecycle_rule.value.prefix
      enabled = tobool(lifecycle_rule.value.enabled)
      noncurrent_version_expiration {
        days = lifecycle_rule.value.expr_days      
      }
      }   
    }
    # Rule for current version file deletion
     dynamic lifecycle_rule {
      for_each = [for s in var.trans_del: {
        prefix  = s[0]
        enabled  = s[1]  
        expr_days     = s[2]  
      }]
      content {
      prefix = lifecycle_rule.value.prefix
      enabled = tobool(lifecycle_rule.value.enabled)  
      expiration {
        days = lifecycle_rule.value.expr_days      
      }
      }   
    }
    #S3 KMS Encryption using KMS key
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = data.aws_kms_key.data_kms_key.arn

        }
      }
    }

  tags = merge(local.common_tags ,var.s3_bucket_tags)
  }
  
  #lake zones 
  resource "aws_s3_bucket_object" "lake_zone" {
    count   = length(var.s3_zones)
    bucket  = aws_s3_bucket.context_bucket.id
    acl     = "private"
    key     = "${var.s3_zones[count.index]}/"
    source  = "/dev/null"
}

#lake zones dataset folders
resource "aws_s3_bucket_object" "lake_zone_data_set" {
  depends_on = [aws_s3_bucket_object.lake_zone]
  count   = length(var.s3_zones_dataset) * length(var.s3_zones)
  bucket  = aws_s3_bucket.context_bucket.id
  acl     = "private"
  key     = "${element(local.product, count.index)[0]}/${element(local.product, count.index)[1]}/"
  source  = "/dev/null"
}

#s3 bucket policy
resource "aws_s3_bucket_policy" "context_bucket_policy" {
  depends_on = [aws_s3_bucket.context_bucket]
  bucket = aws_s3_bucket.context_bucket.id

  policy = <<POLICY
{
  "Id": "https_policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "${aws_s3_bucket.context_bucket.arn}",
        "${aws_s3_bucket.context_bucket.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
POLICY
}

#Block Bucket Pulic Access
resource "aws_s3_bucket_public_access_block" "PublicAccess" {
   depends_on = [aws_s3_bucket_policy.context_bucket_policy]
    bucket = aws_s3_bucket.context_bucket.id
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }

