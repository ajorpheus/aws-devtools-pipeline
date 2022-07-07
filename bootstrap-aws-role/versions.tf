terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
    archive = "~> 2.2.0"
    random  = "3.3.2"
  }
}

module "root_tags" {
  source = "git::https://github.com/cloudposse/terraform-null-label?ref=0.25.0"
  name   = local.common_name_prefix

  namespace  = "Warncl"
  stage      = "dev"
  attributes = ["public"]
  delimiter  = "-"
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Team        = "Wrncl"
      ManagedBy   = "Terraform"
      AppName     = "Wrncl-bootstrap"
      Environment = "Dev"
    }
  }
}
