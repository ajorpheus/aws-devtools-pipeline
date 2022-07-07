locals {
  aws_region = "eu-west-2"
}

remote_state {
  backend  = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "${get_env("TG_PREFIX", "")}terraform-state-wrncl-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "${get_env("TG_PREFIX", "")}terraform-state-wrncl-lock-table-${local.aws_region}"
  }
}
