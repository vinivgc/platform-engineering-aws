terraform {
  required_version = "~> 1.14.0"

  backend "s3" {
    region         = "eu-west-1"
    bucket         = "platform-engineering-aws-tf-state"
    key            = "platform/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "platform-engineering-aws-tf-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36.0"
    }
  }
}