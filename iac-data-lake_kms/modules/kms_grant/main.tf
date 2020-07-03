data "aws_kms_key" "data_kms_key" {
  key_id = var.kms_grant_key_alias
}

resource "aws_kms_grant" "aws_grant" {
  count             =  length(var.kms_grant_end_user)
  name              = "lakeAdminGrant1"
  key_id            = data.aws_kms_key.data_kms_key.id
  grantee_principal = var.kms_grant_end_user[count.index]
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
  retire_on_delete  = "true"
  
}