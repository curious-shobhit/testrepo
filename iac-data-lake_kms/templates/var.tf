
variable "kms_key_alias" {
  description = "KMS Key alias for Newly Created Key"
  }
variable "root_user" {
  description = "Root User for the account to assing to Admin of KMS Key" 
  }

  variable "key_admin" {
  description = "KMS KEY Adminstrator for Newly Created Key"
  }
  
  variable "kms_grant_end_user" {
  description = "End User/Role to grant Access to KMS Acess"
  }

 variable "kms_key_tags" {
 description = "Tags for New KMS Key"

 }



 variable "s3_bucket_domain" {
  description = "Domain to be used in bucket name"
  default = "loan"

}
variable "s3_bucket_name_project" {
  description = "project to be used in bucket name"
  default = "prjphx"

}
variable "s3_bucket_name_region" {
  description = "region to be used in bucket name"
  default = "sg"

}
variable "s3_bucket_name_env" {
  description = "Env to be used in bucket name"
  default = "poc"

}

variable "s3_zones_dataset" {
  type        = list(string)
  description = "The list of S3 dataset"  
}

  variable "s3_bucket_tags"  {
    description = "Tags of s3 bucket"   
  }


variable prv_trans  {
  description = "Bucket LifeCycle for previous version of file"  
}

variable prv_trans_del  {
  description = "Bucket LifeCycle for previous version of file for deletion" 
}


variable trans  {
  description = "Bucket LifeCycle for current version of file "
   
}

variable trans_del {
  description = "Bucket LifeCycle for previous version of file for deletion"  
}



variable "database_description" {
  description = "Description for database"
  
}


