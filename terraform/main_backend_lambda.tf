locals {
  lambda_func_base_name = var.common_name
  lambda_func_file_name = "index.js"

  global_tags = module.root_tags.tags
}

resource "aws_lambda_function" "calc" {
  function_name = "${local.common_name}-${var.environment_name}"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs12.x"

  filename         = data.archive_file.lambda_payload.output_path
  source_code_hash = data.archive_file.lambda_payload.output_base64sha256

  tracing_config {
    mode = "Active"
  }

  tags = merge(local.global_tags, {
    Name           = "${var.common_name}-test-lambdas-simple",
    DeploymentName = var.common_name
  })

  reserved_concurrent_executions = 10
}

data "archive_file" "lambda_payload" {
  type        = "zip"
  output_path = "${path.module}/${local.lambda_func_base_name}.zip"

  source {
    filename = local.lambda_func_file_name
    content  = templatefile("${path.module}/lambdas/${local.lambda_func_file_name}", {})
  }
}
