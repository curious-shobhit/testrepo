variable "s3_bucket_domain" {
  description = "Domain to be used in bucket name"
 }
variable "s3_bucket_name_project" {
  description = "project to be used in bucket name"
  default = "prjphx"

}
variable "s3_bucket_name_region" {
  description = "region to be used in bucket name"
}
variable "s3_bucket_name_env" {
  description = "Env to be used in bucket name"
}
variable "s3_zones" {
  type        = list(string)
  description = "The list of S3 folders to create"
  default     = ["raw", "stage", "clean"]
}

variable "s3_zones_dataset" {
  type        = list(string)
  description = "The list of S3 dataset" 
}

  variable s3_bucket_tags  {
    description = "Tags of s3 bucket"    
  }
variable "kms_grant_key_alias" {
  description = "KMS Key alias"  
}


variable prv_trans  {
  description = "Bucket LifeCycle for previous version of file" 
  #2147483647 - Maximum Possible number of days  ,Around 5000_ years
  #[Lake_zone,is_enabled,s3_storage_type,num_days_for_ia,days_for_del]
  default = [["/raw","true","STANDARD_IA",365]
            ,["/stage","true","STANDARD_IA",360]]
}

variable prv_trans_del  {
  description = "Bucket LifeCycle for previous version of file for deletion" 
  #2147483647 - Maximum Possible number of days  ,Around 5000_ years
  #[Lake_zone,is_enabled,s3_storage_type,num_days_for_ia,days_for_del]
  default = [["/raw","true",2555]             
            ,["/stage","true",2555]]
}


variable trans  {
  description = "Bucket LifeCycle for current version of file "
   #Use 2147483647 if we dont want to delete object ever" 
  default = [["/raw","true","STANDARD_IA",365]
            ,["/stage","true","STANDARD_IA",365]]
   
}

variable trans_del {
  description = "Bucket LifeCycle for previous version of file for deletion"
   #Use 2147483647 if we dont want to delete object ever" 
  default = [["/raw","true",2555]
            ,["/stage","true",2555]]   
}


