resource "aws_ssm_parameter" "github_token" {
  name  = "github_token_${local.common_name_prefix}"
  type  = "String"
  value = var.github_token
}
