#creating kms_key setup 
data "aws_ssm_parameter" "root_user" {
  name = var.root_user
}

data "aws_ssm_parameter" "key_admin" {
  name = var.key_admin
}

module "kms_key" {
  source   = "../modules/kms_key" 
  kms_key_alias = var.kms_key_alias
  root_user = data.aws_ssm_parameter.root_user.value
  key_admin = data.aws_ssm_parameter.key_admin.value
  kms_key_tags =var.kms_key_tags
}

#providing kms_grant
module "kms_grant" {  
  source   = "../modules/kms_grant"
  kms_grant_end_user = var.kms_grant_end_user
  kms_grant_key_alias = module.kms_key.kms_key_id

}

#Creating S3 Bucket
module "s3_bucket" {
  source   = "../modules/s3_bucket" 
  kms_grant_key_alias   = module.kms_key.kms_key_alias
  s3_bucket_domain      = var.s3_bucket_domain
  s3_bucket_name_region = var.s3_bucket_name_region
  s3_bucket_name_env    = var.s3_bucket_name_env
  s3_zones_dataset      = var.s3_zones_dataset
  s3_bucket_tags        = var.s3_bucket_tags
  prv_trans             = var.prv_trans
  prv_trans_del         = var.prv_trans_del
  trans                 = var.trans
  trans_del             = var.trans_del
}

#Register S3 Location in Lake Formation 
resource "null_resource" "lakeformationregisterS3" {
  provisioner "local-exec" {
    command =  "aws lakeformation register-resource --resource-arn ${module.s3_bucket.context_bucket_arn} --use-service-linked-role"
    
  }
}

#Creating LakeDatabase
module "lake_database" {
  source   = "../modules/lake_database" 
  s3_bucket_domain      = var.s3_bucket_domain
  bucket_id             = module.s3_bucket.context_bucket
  database_description  = var.database_description
}

#Create Tables 
  resource "null_resource" "create_table" {
    count             =  length(var.s3_zones_dataset)
    provisioner "local-exec" {
      command =  "python3 ../modules/lake_tables/table.py ${module.lake_database.database_name} ${module.s3_bucket.context_bucket} ${var.s3_bucket_domain} ${var.s3_zones_dataset[count.index]}" 
      
    }    
  }
