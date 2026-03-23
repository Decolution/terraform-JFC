terraform {
  backend "s3" {
    bucket = "jfc-ecommerce-terraform-state"
    key = "prod/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "jfc-ecommerce-terraform-locks"
  }
}