//---------------------------------------------------------
// Inputs

resource "random_string" "random_name" {
  count   = var.team_name != "" ? 0 : 1
  length  = 6
  special = false
}

variable "team_name" {
  type        = string
  description = "Common prefix for resources"
  default     = ""
}

//---------------------------------------------------------
// Resources
data "aws_caller_identity" "current" {}
locals {
  account_id         = data.aws_caller_identity.current.account_id
  common_name_prefix = local.team_name
  team_name          = var.team_name != "" ? var.team_name : lower(join("-", random_string.random_name.*.result))
}

module "aws_oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "0.8.0"

  github_thumbprint    = var.github_thumbprint
  iam_role_name        = "${local.common_name_prefix}-deployment-role-oidc"
  iam_role_path        = var.iam_role_path
  iam_role_policy_arns = var.iam_role_policy_arns
  github_repositories  = var.github_repositories
  tags                 = module.root_tags.tags

  iam_role_inline_policies = {
    "inline_policy" : data.aws_iam_policy_document.oidc_role_inline_policy.json
  }
}

data "aws_iam_policy_document" "oidc_role_inline_policy" {
  statement {
    sid    = "KMSManagement"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:DescribeKey",
      "kms:EnableKeyRotation",
      "kms:Encrypt",
      "kms:Get*",
      "kms:List*",
      "kms:PutKeyPolicy",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ReplicateKey",
      "kms:*Alias"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSManagement"
    effect = "Allow"
    actions = [
      "sns:AddPermission",
      "sns:ConfirmSubscription",
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:GetSubscriptionAttributes",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTagsForResource",
      "sns:ListTopics",
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:Subscribe",
      "sns:TagResource",
      "sns:Unsubscribe",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "RoleManagement"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:TagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole*",
      "iam:GetPolicy*",
      "iam:ListPolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListRole*",
      "iam:ListInstanceProfilesForRole",
      "iam:ListEntitiesForPolicy",
      "iam:CreateServiceLinkedRole",
      "iam:UpdateRoleDescription",
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "APIGWManagement"
    effect = "Allow"
    actions = [
      "apigateway:DELETE",
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:UpdateRestApiPolicy",
      "apigateway:AddCertificateToDomain",
      "apigateway:PutIntegration",
      "acm:ImportCertificate",
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate",
      "acm:DeleteCertificate",
      "execute-api:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "LambdaManagement"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:ListVersionsByFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:DeleteFunction",
      "lambda:TagResource",
      "lambda:AddPermission",
      "lambda:*Layer*",
      "lambda:RemovePermission",
      "iam:PassRole",
      "logs:CreateLogGroup",
      "logs:ListTagsLogGroup",
      "logs:DeleteLogGroup",
      "logs:Describe*",
      "logs:GetLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutMetricFilter",
      "logs:DeleteMetricFilter",
      "logs:DeleteLogGroup"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ec2"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:List*",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CustomDomainForAPIGW"
    effect = "Allow"
    actions = [
      "acm:RequestCertificate"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "Route53ForAPIGW"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CloudwatchManagement"
    effect = "Allow"

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:List*",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
    ]

    resources = ["*"]
  }
}
