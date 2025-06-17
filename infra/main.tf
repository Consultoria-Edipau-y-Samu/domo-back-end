terraform {
  backend "s3" {
    bucket         = "domo-terraform-state-bucket"
    key            = "backend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-domo"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
