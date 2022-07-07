resource "aws_kms_key" "uuid_app" {
  description             = "KMS Key for ${local.common_name}-uuid"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.cognito_ses_notifications.json
}

data "aws_iam_policy_document" "cognito_ses_notifications" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
    ]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com", "codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow access through SNS for all principals in the account that are authorized to use SNS"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["sns.${local.account_id}.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}


resource "aws_kms_alias" "uuid_app" {
  name          = "alias/${local.common_name}-uuid"
  target_key_id = aws_kms_key.uuid_app.key_id
}

#tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "uuid_app" {
  bucket        = "${local.common_name}-uuid-bucket"
  tags          = module.root_tags.tags
  force_destroy = true
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.uuid_app.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uuid_app" {
  bucket = aws_s3_bucket.uuid_app.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.uuid_app.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "non-public" {
  bucket                  = aws_s3_bucket.uuid_app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_codepipeline" "uuid_app_pipeline" {
  name     = "${local.common_name}-codep-uuid"
  role_arn = aws_iam_role.uuid_app_cp.arn
  tags     = module.root_tags.tags

  artifact_store {
    location = aws_s3_bucket.uuid_app.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.uuid_app.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name      = "Source"
      category  = "Source"
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"

      configuration = {
        "Branch"               = var.github_repository.branch
        "Owner"                = var.github_repository.owner
        "PollForSourceChanges" = var.github_repository.poll_for_change
        "Repo"                 = var.github_repository.name
        "OAuthToken"           = var.github_token
      }

      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]
    }
  }
  stage {
    name = "Build"

    action {
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"

      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.environment_name
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.uuid_app.name
      }

      input_artifacts  = ["SourceArtifact"]
      name             = "Build"
      output_artifacts = ["BuildArtifact"]

    }
  }
  stage {
    name = "Deploy"

    action {
      name            = "CreateUpdateStack"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ActionMode     = "REPLACE_ON_FAILURE"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "outputTemplate.yaml"
        StackName      = local.stack_name
        TemplatePath   = "BuildArtifact::outputTemplate.yaml"
        RoleArn        = aws_iam_role.cloudformation_permissions.arn
      }
    }

    action {
      name            = "CreateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2

      configuration = {
        ActionMode    = "CHANGE_SET_REPLACE"
        Capabilities  = "CAPABILITY_IAM"
        StackName     = local.stack_name
        ChangeSetName = "${local.stack_name}-changeset"
        TemplatePath  = "BuildArtifact::outputTemplate.yaml"
        RoleArn       = aws_iam_role.cloudformation_permissions.arn
      }
    }

    action {
      name      = "ExecuteChangeset"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "CloudFormation"
      version   = "1"
      run_order = 3

      configuration = {
        ActionMode    = "CHANGE_SET_EXECUTE"
        Capabilities  = "CAPABILITY_IAM"
        StackName     = local.stack_name
        ChangeSetName = "${local.stack_name}-changeset"
      }
    }
  }
}


resource "aws_iam_role" "cloudformation_permissions" {
  name               = "${local.stack_name}-cloudformation-role"
  assume_role_policy = data.aws_iam_policy_document.uuid_app_cf_trust_policy.json
  tags               = module.root_tags.tags
}


data "aws_iam_policy_document" "uuid_app_cf_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "cloudformation.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "uuid_app_cf" {
  policy = data.aws_iam_policy_document.cloudformation_inline_policy.json
  role   = aws_iam_role.cloudformation_permissions.id
}


#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "cloudformation_inline_policy" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudformation:CreateChangeSet",
      "events:DeleteRule",
      "events:DescribeEventBus",
      "events:DescribeRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:ListRuleNamesByTarget",
      "events:ListRules",
      "events:ListTagsForResource",
      "events:ListTargetsByRule",
      "events:PutEvents",
      "events:PutPermission",
      "events:PutRule",
      "events:PutTargets",
      "events:RemovePermission",
      "events:RemoveTargets",
      "events:TagResource",
      "events:TestEventPattern",
      "events:UntagResource",
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "lambda:*",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "sns:*",
      "ec2:*",
      "apigateway:*"
    ]
  }

  statement {
    sid       = "CloudwatchLogs"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid    = "DynamoDBPermissions"
    effect = "Allow"

    resources = [
      "arn:aws:dynamodb:eu-west-2:194254006862:table/uuid-job-name-map",
      "arn:aws:dynamodb:eu-west-2:194254006862:table/uuid-job-name-map/index/*",
    ]

    actions = [
      "dynamodb:*",
    ]
  }
}
