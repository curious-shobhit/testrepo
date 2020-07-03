variable "kms_grant_end_user" {
  description = "List for End User/Role to be granted as KMS Key User"
  type    = list(string)
}

variable "kms_grant_key_alias" {  
  description = "KMS Key alias for Newly Created Key"
  }


