locals {
  stage_name = "main"
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "main" {
  name = "${var.common_name}-calctf"
  tags = module.root_tags.tags

  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_resource" "calc" {
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "calc"
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "get" {
  authorization    = "AWS_IAM"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.calc.id
  rest_api_id      = aws_api_gateway_rest_api.main.id
  api_key_required = false

  request_parameters = {
    "method.request.querystring.operand1" = true
    "method.request.querystring.operand2" = true
    "method.request.querystring.operator" = true
  }
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "${aws_api_gateway_resource.calc.path_part}/${aws_api_gateway_method.get.http_method}"

  settings {
    metrics_enabled      = true
    logging_level        = "INFO"
    data_trace_enabled   = true
    caching_enabled      = true
    cache_data_encrypted = true
  }
}

resource "aws_api_gateway_method_settings" "all_stages" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*" # <----- ⚠⚠⚠⚠⚠⚠ THIS MAKES THIS BLOCK APPLICABLE TO WHOLE STAGE

  settings {
    metrics_enabled      = true
    logging_level        = "INFO"
    data_trace_enabled   = true
    cache_data_encrypted = true
    caching_enabled      = true
  }
}

#tfsec:ignore:aws-api-gateway-enable-tracing
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "${var.common_name}-calctf"

  # ⚠⚠⚠⚠⚠⚠ START
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_stage.arn
    format = jsonencode(
      {
        "caller"         = "$context.identity.caller",
        "httpMethod"     = "$context.httpMethod",
        "ip"             = "$context.identity.sourceIp",
        "protocol"       = "$context.protocol",
        "requestId"      = "$context.requestId",
        "requestTime"    = "$context.requestTime",
        "resourcePath"   = "$context.resourcePath",
        "responseLength" = "$context.responseLength",
        "status"         = "$context.status",
        "user"           = "$context.identity.user",
        "errorMessage"   = "$context.error.messageString"
      }
    )
  }
  # ⚠⚠⚠⚠⚠⚠ END
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "apigw_stage" {
  #checkov:skip=CKV_AWS_158: To be Done ("Ensure that CloudWatch Log Group is encrypted by KMS")
  name              = "access-log-for-apigw-stage-${local.stage_name}"
  retention_in_days = 90
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.calc.id,
      aws_api_gateway_method.get.id,
      aws_api_gateway_integration.this.id,
    ]))
  }
  depends_on = [aws_api_gateway_integration.this, aws_lambda_function.calc]

  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.calc.id
  http_method             = aws_api_gateway_method.get.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path//2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.calc.function_name}/invocations"
  credentials             = aws_iam_role.lambda_role.arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  timeout_milliseconds    = 29000

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  # Transforms the incoming message to JSON
  request_templates = {
    "application/json" = <<EOF
{
    "a":  "$input.params('operand1')",
    "b":  "$input.params('operand2')",
    "op": "$input.params('operator')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.calc.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.calc.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [aws_api_gateway_integration.this]
}

resource "aws_api_gateway_rest_api_policy" "apigw_resource_policy" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "apigw_resource_policy"
    Statement = {
      Effect   = "Allow"
      Resource = ["*"]
      Action   = ["execute-api:*"]

      Principal = {
        AWS = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          var.deployment_role
        ]
      }
    }
  })
}


resource "aws_iam_role" "apigw_lambda" {
  name               = "${local.common_name}-calctf"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  ]
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
    }
  }
}
