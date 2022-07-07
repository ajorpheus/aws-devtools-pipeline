resource "aws_iam_role" "uuid_app_cb" {
  name               = "${local.common_name}-cb-service-role"
  assume_role_policy = data.aws_iam_policy_document.uuid_app_cb_trust_policy.json
  tags               = module.root_tags.tags
}

data "aws_iam_policy_document" "uuid_app_cb_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "uuid_app_cb_service_linked" {
  policy = data.aws_iam_policy_document.inline_policy.json
  role   = aws_iam_role.uuid_app_cb.id
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "inline_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:logs:eu-west-2:${local.account_id}:log-group:/aws/codebuild/*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::codepipeline-eu-west-2-*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codebuild:eu-west-2:${local.account_id}:report-group/*"]

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
  }

  statement {
    sid       = "ListObjectsInBucket"
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]
    actions   = ["s3:ListBucket"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = [aws_kms_key.uuid_app.arn]
    actions   = ["kms:*"]
  }

  statement {
    sid       = "AllObjectActions"
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]
    actions   = ["s3:*Object"]
  }
}
