##You need to hardcode bucket name below
terraform {
  backend "s3" {
    encrypt = "true"
  }
}
