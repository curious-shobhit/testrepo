
#DeRegister S3 location
  resource "null_resource" "lakeformationDeRegisterS3" {
    provisioner "local-exec" {
      command =  "aws lakeformation deregister-resource --resource-arn ${aws_s3_bucket.dummy-context-bucket.arn} ;sleep 10"
      
    }
  }

#Create S3 Bucket
  resource "aws_s3_bucket" "dummy-context-bucket" {
    bucket = var.bucket_name
    acl    = "private"
    versioning {
      enabled = true

    }
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "AES256"
        }
      }
    }
    tags = {
      Name        = "DummyContextBucket"
      Environment = "Dev"
      Remark      = "Dummy Data"
    }
  }
  resource "aws_s3_bucket_public_access_block" "PublicAccess" {
    bucket = "${aws_s3_bucket.dummy-context-bucket.id}"

    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }

#Add Admin to Lake
  resource "null_resource" "lakeformationRegisterAdminPipleLineRole" {
    depends_on = [aws_iam_role.LakeAdmin]
    provisioner "local-exec" {
      command =  "sleep 15 ;aws lakeformation put-data-lake-settings --data-lake-settings '{\"DataLakeAdmins\": [{\"DataLakePrincipalIdentifier\": \"${var.pipe_line_role_arn}\"},{\"DataLakePrincipalIdentifier\": \"${aws_iam_role.LakeAdmin.arn}\"}]}'" 
     }
  }

#Register S3 location
  resource "null_resource" "lakeformationRegisterS3" {
    depends_on = [aws_s3_bucket.dummy-context-bucket,null_resource.lakeformationRegisterAdminPipleLineRole]
    provisioner "local-exec" {
      command =  "sleep 15;aws lakeformation register-resource --resource-arn ${aws_s3_bucket.dummy-context-bucket.arn} --use-service-linked-role"
      
    }
  }


#Create GlueRole
  resource "aws_iam_role" "DatalakeGlueRole" {
    name = "DatalakeGlueRole"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
    tags = {
      Name        = "DatalakeGlueRole"
      Environment = "Dev"
      Remark      = "Glue Role for Crawler"
    }
  }
  resource "aws_iam_role_policy_attachment" "policy_glue_service_role" {
    role       = "${aws_iam_role.DatalakeGlueRole.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  }
#Create Database  
  resource "aws_glue_catalog_database" "LakeDatabaseDummyContext" {
    depends_on = [null_resource.lakeformationRegisterAdminPipleLineRole]  
    name = "${var.database_name}"
    location_uri = "s3://${aws_s3_bucket.dummy-context-bucket.id}"
    }

#Add Databse Permission to glue 
  resource "null_resource" "gluedatabsepermission" {
    depends_on = [aws_iam_role.DatalakeGlueRole,null_resource.lakeformationRegisterAdminPipleLineRole]    
    provisioner "local-exec" {
     command =  "sleep 15;aws lakeformation grant-permissions --principal DataLakePrincipalIdentifier=${aws_iam_role.DatalakeGlueRole.arn} --permissions \"CREATE_TABLE\" \"ALTER\" --resource '{ \"Database\": {\"Name\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\"}}'"

    }
  }

#CreateTables curated 
  resource "aws_glue_catalog_table" "curated_table" {
    depends_on = [aws_glue_catalog_database.LakeDatabaseDummyContext]
    name          = "loan_curated"
    database_name = "${aws_glue_catalog_database.LakeDatabaseDummyContext.name}"

    table_type = "EXTERNAL_TABLE"

    parameters = {
      classification        = "CSV"
    }

    storage_descriptor {
      location      = "s3://${aws_s3_bucket.dummy-context-bucket.id}/curated/"
      input_format  = "org.apache.hadoop.mapred.TextInputFormat"
      output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

      ser_de_info {
        name                  = "loan_raw"
        serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

        parameters = {
          separatorChar = ";"
        }
      }

      columns {
        name = "loan_id"
        type = "int"
      }

      columns {
        name = "account_id"
        type = "int"
      }

      columns {
        name    = "Date"
        type    = "string"
        comment = ""
      }

      columns {
        name    = "amount"
        type    = "double"
        comment = ""
      }

      columns {
        name    = "duration"
        type    = "int"
        comment = ""
      }
      columns {
        name    = "payments"
        type    = "double"
        comment = ""
      }
      columns {
        name    = "status"
        type    = "string"
        comment = ""
      }
    }
  }

#CreateTable  Clean 

  resource "aws_glue_catalog_table" "clean_table" {
      depends_on = [aws_glue_catalog_database.LakeDatabaseDummyContext]
      name          = "loan_clean"
      database_name = "${aws_glue_catalog_database.LakeDatabaseDummyContext.name}"

      table_type = "EXTERNAL_TABLE"

      parameters = {
        classification        = "CSV"
      }

      storage_descriptor {
        location      = "s3://${aws_s3_bucket.dummy-context-bucket.id}/clean/"
        input_format  = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

        ser_de_info {
          name                  = "loan_raw"
          serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

          parameters = {
            separatorChar = ";"
          }
        }

        columns {
          name = "loan_id"
          type = "int"
        }

        columns {
          name = "account_id"
          type = "int"
        }

        columns {
          name    = "Date"
          type    = "string"
          comment = ""
        }

        columns {
          name    = "amount"
          type    = "double"
          comment = ""
        }

        columns {
          name    = "duration"
          type    = "int"
          comment = ""
        }
        columns {
          name    = "payments"
          type    = "double"
          comment = ""
        }
        columns {
          name    = "status"
          type    = "string"
          comment = ""
        }
      }
    }


#Curated Table Permission
  #Add Databse table Permission to  pii user 
    resource "null_resource" "piiuseraccess" {
      depends_on = [aws_iam_role.dummy_lake_pii,null_resource.lakeformationRegisterAdminPipleLineRole]   
      provisioner "local-exec" {
        command =  "sleep 15 ; aws lakeformation grant-permissions --principal DataLakePrincipalIdentifier=${aws_iam_role.dummy_lake_pii.arn} --permissions \"SELECT\" --resource '{ \"Table\": {\"DatabaseName\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\" , \"Name\":\"${aws_glue_catalog_table.curated_table.name}\" }}'"
      }
    }
  #Add Databse table Permission to  non pii user 
    resource "null_resource" "non_piiuseraccess" {
      depends_on = [aws_iam_role.dummy_lake_non_pii,null_resource.lakeformationRegisterAdminPipleLineRole]   
      provisioner "local-exec" {
        command =  "sleep 15 ;aws lakeformation grant-permissions --principal DataLakePrincipalIdentifier=${aws_iam_role.dummy_lake_non_pii.arn} --permissions \"SELECT\" --resource '{ \"TableWithColumns\": {\"DatabaseName\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\" , \"Name\":\"${aws_glue_catalog_table.curated_table.name}\" , \"ColumnWildcard\": {\"ExcludedColumnNames\": [\"amount\",\"payments\"]}}}'"
      }
    }
  #revoke Databse Permission from IAM allowed
    resource "null_resource" "IAMALLOWED" {
      depends_on = [aws_glue_catalog_table.curated_table,null_resource.lakeformationRegisterAdminPipleLineRole]    
      provisioner "local-exec" {
        command =  "sleep 15;aws lakeformation revoke-permissions --principal DataLakePrincipalIdentifier=EVERYONE --permissions \"ALL\" --resource '{ \"Table\": {\"DatabaseName\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\" , \"Name\":\"${aws_glue_catalog_table.curated_table.name}\" }}'"
      }
    }

#Clean Table Permission
  #Add Databse table Permission to  pii user 
    resource "null_resource" "piiuseraccess1" {
      depends_on = [aws_iam_role.dummy_lake_pii,null_resource.lakeformationRegisterAdminPipleLineRole]   
      provisioner "local-exec" {
        command =  "sleep 15 ; aws lakeformation grant-permissions --principal DataLakePrincipalIdentifier=${aws_iam_role.dummy_lake_pii.arn} --permissions \"SELECT\" --resource '{ \"Table\": {\"DatabaseName\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\" , \"Name\":\"${aws_glue_catalog_table.clean_table.name}\" }}'"
      }
    }
  #Add Databse table Permission to  non pii user 
    resource "null_resource" "non_piiuseraccess1" {
      depends_on = [aws_iam_role.dummy_lake_non_pii,null_resource.lakeformationRegisterAdminPipleLineRole]   
      provisioner "local-exec" {
        command =  "sleep 15 ;aws lakeformation grant-permissions --principal DataLakePrincipalIdentifier=${aws_iam_role.dummy_lake_non_pii.arn} --permissions \"SELECT\" --resource '{ \"TableWithColumns\": {\"DatabaseName\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\" , \"Name\":\"${aws_glue_catalog_table.clean_table.name}\" , \"ColumnWildcard\": {\"ExcludedColumnNames\": [\"amount\",\"payments\"]}}}'"
      }
    }
  #revoke Databse Permission from IAM allowed
    resource "null_resource" "IAMALLOWED1" {
      depends_on = [aws_glue_catalog_table.clean_table,null_resource.lakeformationRegisterAdminPipleLineRole]    
      provisioner "local-exec" {
        command =  "sleep 15;aws lakeformation revoke-permissions --principal DataLakePrincipalIdentifier=EVERYONE --permissions \"ALL\" --resource '{ \"Table\": {\"DatabaseName\":\"${aws_glue_catalog_database.LakeDatabaseDummyContext.name}\" , \"Name\":\"${aws_glue_catalog_table.clean_table.name}\" }}'"
      }
    }




