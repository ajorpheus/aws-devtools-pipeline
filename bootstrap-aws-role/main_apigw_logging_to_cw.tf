# IAM policy document to allow assume role for api gateway logging
data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
      ]
    }
  }
}

# Role creation
resource "aws_iam_role" "api-cloudwatch-access-role" {
  name               = "api-cloudwatch-access-role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  ]

  tags = module.root_tags.tags
}

# API Gateway account settings
resource "aws_api_gateway_account" "api-account" {
  cloudwatch_role_arn = aws_iam_role.api-cloudwatch-access-role.arn
}
