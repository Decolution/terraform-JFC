terraform {
  backend "s3" {
    bucket         = "jfc-ecommerce-terraform-state-637423321139-us-east-1-an"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "jfc-ecommerce-terraform-locks"
    encrypt        = true
  }
}