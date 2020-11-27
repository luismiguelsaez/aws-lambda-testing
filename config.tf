terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
   region = "eu-west-1"
}

### Data sources used by other resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}