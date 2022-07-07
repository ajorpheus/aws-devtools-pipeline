variable "github_repositories" {
  description = "List of GitHub organization/repository names authorized to assume the role."
  type        = list(string)
  default = [
    "ajorpheus/aws-devtools-pipeline"
  ]

  validation {
    // Ensures each element of github_repositories list matches the
    // organization/repository format used by GitHub.
    condition = length([
      for repo in var.github_repositories : 1
      if length(regexall("^[A-Za-z0-9_.-]+?/([A-Za-z0-9_.:/-]+|\\*)$", repo)) > 0
    ]) == length(var.github_repositories)
    error_message = "Repositories must be specified in the organization/repository format."
  }
}

// See: https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/
variable "github_thumbprint" {
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
  description = "GitHub OpenID TLS certificate thumbprint."
  type        = string
}

variable "iam_role_name" {
  default     = "github-oidc-role"
  description = "Name of the IAM role to be created. This will be assumable by GitHub."
  type        = string
}

variable "iam_role_path" {
  default     = "/github/"
  description = "Path under which to create IAM role."
  type        = string
}

variable "iam_role_policy_arns" {
  default = [
    "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
    "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator",
  ]
  description = "List of IAM policy ARNs to attach to the IAM role."
  type        = list(string)
}

variable "region" {
  description = "AWS region in which to apply resources."
  type        = string
  default     = "eu-west-2"
}

variable "github_token" {
  description = "Github Personal Access Token"
}
