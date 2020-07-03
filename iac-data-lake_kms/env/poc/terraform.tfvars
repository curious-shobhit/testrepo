  kms_key_alias = "alias/kms/data_team7"
  root_user = "/CodeBuild/data-squad/root_user"
  key_admin = "/CodeBuild/data-squad/key_admin" 
  kms_grant_end_user = ["arn:aws:iam::072496178032:role/non_pii_user",
                        "arn:aws:iam::072496178032:role/pii_user",
                        "arn:aws:iam::072496178032:user/shobit"]
  
  kms_key_tags = {
      
    Name        = "DATA KMS KEY"
    Environment = "POC"
    Remark      = "FOR S3 EMR REDSHIFT"
    
}

#S3 Bucket

s3_bucket_domain = "loan"
s3_bucket_name_region = "sg"
s3_bucket_name_env= "poc"
#s3_zones_dataset = ["crm", "loan", "payments"]
s3_zones_dataset = ["crm"]

s3_bucket_tags  = {    
      Source              = "SCB"
      Security_Boundaries = "Only Loan and Risk Department can use"
      Downstream_Use      = "SPARK/REDSHIFT SPECTURM/BI"
      Data_Load_Pattern   = "BATCH:Incremental"
      Domain_Owner        = "Loan SME"
    }

prv_trans = [["/raw","true","STANDARD_IA",365]
            ,["/stage","true","STANDARD_IA",360]]


prv_trans_del  = [["/raw","true",2555]             
            ,["/stage","true",2555]]


trans = [["/raw","true","STANDARD_IA",365]
            ,["/stage","true","STANDARD_IA",360]]


trans_del  = [["/raw","true",2555]             
            ,["/stage","true",2555]]

database_description = "Lake Database for Loan Data"