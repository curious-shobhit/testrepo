#User Creation
  resource "aws_iam_user" "la" {
    name = "scb.data.lake.admin"

    tags = {
      Name        = "LakeAdminUser"
      Environment = "Dev"
      Remark      = "Dummy Admin User"
    }
  }

  resource "aws_iam_user" "lu_pii" {
    name = "scb.data.dummy.pii"

    tags = {
      Name        = "DummyPIIUSerLakeAdminUser"
      Environment = "Dev"
      Remark      = "Dummy Admin User"
    }
  }
  resource "aws_iam_user" "lu_non_pii" {
    name = "scb.data.dummy"

    tags = {
      Name        = "DummyUser"
      Environment = "Dev"
      Remark      = "Dummy Admin User"
    }
  }

#PII User Role
  resource "aws_iam_role" "dummy_lake_pii" {
    name = "pii_user"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": [
                  "${aws_iam_user.lu_pii.arn}"
          ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

    tags = {
      Name        = "PII Role User"
      Environment = "Dev"
      Remark      = "Dummy PII  User"
    }
  }
  resource "aws_iam_role_policy_attachment" "policy_Athena_dummy_lake_pii" {
    role       = "${aws_iam_role.dummy_lake_pii.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
  }
  resource "aws_iam_role_policy_attachment" "lpolicy_glue_dummy_lake_pii" {
    role       = "${aws_iam_role.dummy_lake_pii.name}"
    policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
  }



#NON PII User Role

  resource "aws_iam_role" "dummy_lake_non_pii" {
    name = "non_pii_user"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": [
                  "${aws_iam_user.lu_non_pii.arn}"
          ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

    tags = {
      Name        = "DummyPIIUSerLakeAdminUser"
      Environment = "Dev"
      Remark      = "Dummy Non PII  User"
    }
  }
  resource "aws_iam_role_policy_attachment" "policy_Athena_dummy_lake_non_pii" {
    role       = "${aws_iam_role.dummy_lake_non_pii.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
  }
  resource "aws_iam_role_policy_attachment" "policy_glue_dummy_lake_non_pii" {
    role       = "${aws_iam_role.dummy_lake_non_pii.name}"
    policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
  }
#LakeAdmin  User Role
  resource "aws_iam_role" "LakeAdmin" {
    name = "LakeAdmin"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": [
                  "${aws_iam_user.la.arn}"
          ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

    tags = {
      Name        = "My Lake Admin Role"
      Environment = "Dev"
      Remark      = "Dummy Data"
    }
  }
  resource "aws_iam_role_policy_attachment" "lakeAdminAttach" {
    role       = "${aws_iam_role.LakeAdmin.name}"
    policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin"
  }
