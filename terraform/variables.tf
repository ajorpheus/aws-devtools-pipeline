variable "common_name" {
  default = "warnacle"
  type    = string
}

resource "random_string" "random_name" {
  count   = var.common_name != "" ? 0 : 1
  length  = 6
  special = false
}

locals {
  common_name = var.common_name != "" ? var.common_name : lower(join("-", random_string.random_name.*.result))
  account_id  = data.aws_caller_identity.current.account_id
  region      = "eu-west-2"
  stack_name  = "wrncl-codep-uuid-stack"
}

variable "environment_name" {
  default = "dev"
}

variable "deployment_role" {
  type = string
}

variable "github_repository" {
  type = object({
    branch          = string
    owner           = string
    name            = string
    poll_for_change = bool
  })

  default = {
    branch          = "master"
    owner           = "ajorpheus"
    name            = "aws-devtools-pipeline"
    poll_for_change = true
  }
}

variable "github_token" {
  description = "Github Personal Access Token"
}
