  kms_key_alias = "alias/kms/phx_data_platform"
  root_user = "arn:aws:iam::036217337260:root"
  key_admin = "arn:aws:iam::036217337260:role/master-pipeline-role" 
  kms_grant_end_user = ["arn:aws:iam::036217337260:role/master-pipeline-role"]
  
  kms_key_tags = {
      
    Name        = "DATA PLATFORM KMS KEY"
    Environment = "DEV"
    Remark      = "FOR S3,EMR ,REDSHIFT"
    
}

