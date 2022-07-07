output "iam_role_arn" {
  description = "ARN of the IAM role."
  value       = module.aws_oidc_github.iam_role_arn
}

output "aws_region" {
  description = "AWS Region"
  value       = var.region
}
