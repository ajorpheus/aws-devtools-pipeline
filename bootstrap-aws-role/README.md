<!-- vim-markdown-toc GFM -->

* [Description](#description)
    * [Pre-requisites](#pre-requisites)
    * [Usage](#usage)
        * [1. Generate Github Token](#1-generate-github-token)
        * [2. Execute script](#2-execute-script)
        * [2.1 Using `aws-vault`](#21-using-aws-vault)
            * [2.1 Using AWS credentials directly](#21-using-aws-credentials-directly)

<!-- vim-markdown-toc -->

# Description

The bash scripts in `bootrap-aws-role` directory do the following:

1. Create the Github OIDC identity provider in AWS with a linked AWS IAM Role using Terraform.
    This allows  configured repositories to assume the role created as a part of the above to access AWS resources via web identity federation.
    The primary benefit of this is that the Github repository does not need any long lived AWS credential secrets.
1. Creates the required secrets (the OIDC Role and AWS Region) in the Github repository.

## Pre-requisites

1. AWS Account credentials in the shell session
1. GH_TOKEN ( Generated using [this link](https://github.com/settings/tokens/new?description=wrncl-poc&scopes=repo) )

The pre-requisites for the bash script itself are wrapped in an `aws-script-executor` docker container, which expects
AWS_* credentials variables in the executing shell's env.

The bootstrap script will fail fast if the required credentials are not present in the env.
It also uses an `aws sts get-caller-identity` as a smoke test to confirm that the provided AWS credentials work.

## Usage

### 0. Clone the Repository

```bash
## With the Github CLI
gh repo clone ajorpheus/aws-devtools-pipeline

## Or, using git
git clone https://github.com/ajorpheus/aws-devtools-pipeline.git
```

### 1. Generate Github Token

Generate a Github PAT using [this](https://github.com/settings/tokens/new?description=wrncl-poc&scopes=repo) link and export it in the shell environment:

```bash
## Export GH_TOKEN
export GH_TOKEN=<github_token_here>
```

### 2. Execute script

Use one of the following to execute the script.

### 2.1 Using [`aws-vault`](https://github.com/99designs/aws-vault#quick-start)

If you use [`aws-vault`](https://github.com/99designs/aws-vault#quick-start) for AWS credentials management, then the command is:

```bash
## cd to the root of the repository
cd "$(git rev-parse --show-toplevel)"

## Check that aws credentials work
aws-vault exec "<AWS_PROFILE_NAME_HERE>" -- aws sts get-caller-identity

## Execute script
aws-vault exec "<AWS_PROFILE_NAME_HERE>" -- bootstrap-aws-role/runme.sh
```

#### 2.1 Using AWS credentials directly

Your shell session must have the AWS_* creds in the env. Check this is the case, by executing the following:

```bash
## cd to the root of the repository
cd "$(git rev-parse --show-toplevel)"

## Check that aws credentials work
aws sts get-caller-identity

## Execute script
bootstrap-aws-role/runme.sh
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.21.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_oidc_github"></a> [aws\_oidc\_github](#module\_aws\_oidc\_github) | unfunco/oidc-github/aws | 0.8.0 |
| <a name="module_root_tags"></a> [root\_tags](#module\_root\_tags) | git::https://github.com/cloudposse/terraform-null-label | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.api-account](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_account) | resource |
| [aws_iam_role.api-cloudwatch-access-role](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role) | resource |
| [aws_ssm_parameter.github_token](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/ssm_parameter) | resource |
| [random_string.random_name](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.oidc_role_inline_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | List of GitHub organization/repository names authorized to assume the role. | `list(string)` | <pre>[<br>  "ajorpheus/aws-devtools-pipeline"<br>]</pre> | no |
| <a name="input_github_thumbprint"></a> [github\_thumbprint](#input\_github\_thumbprint) | GitHub OpenID TLS certificate thumbprint. | `string` | `"6938fd4d98bab03faadb97b34396831e3780aea1"` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | Github Personal Access Token | `any` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to be created. This will be assumable by GitHub. | `string` | `"github-oidc-role"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path under which to create IAM role. | `string` | `"/github/"` | no |
| <a name="input_iam_role_policy_arns"></a> [iam\_role\_policy\_arns](#input\_iam\_role\_policy\_arns) | List of IAM policy ARNs to attach to the IAM role. | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",<br>  "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",<br>  "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess",<br>  "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",<br>  "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",<br>  "arn:aws:iam::aws:policy/AmazonS3FullAccess",<br>  "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",<br>  "arn:aws:iam::aws:policy/AWSLambda_FullAccess",<br>  "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region in which to apply resources. | `string` | `"eu-west-2"` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Common prefix for resources | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS Region |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
