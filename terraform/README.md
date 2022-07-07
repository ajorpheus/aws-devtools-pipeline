# terraform

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
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.21.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 4.26.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_root_tags"></a> [root\_tags](#module\_root\_tags) | git::https://github.com/cloudposse/terraform-null-label | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.this](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.get](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.response_200](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.all_stages](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.calc](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.main](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api_policy.apigw_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_rest_api_policy) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/api_gateway_stage) | resource |
| [aws_cloudwatch_log_group.apigw_stage](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.uuid_app](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.uuid_app_pipeline](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/codepipeline) | resource |
| [aws_codepipeline_webhook.codepipeline_webhook](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/codepipeline_webhook) | resource |
| [aws_iam_role.apigw_lambda](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role) | resource |
| [aws_iam_role.cloudformation_permissions](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role) | resource |
| [aws_iam_role.uuid_app_cb](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role) | resource |
| [aws_iam_role.uuid_app_cp](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.uuid_app_cb_service_linked](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.uuid_app_cf](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.uuid_app_cp_service_linked](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.AWSLambda](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AWSLambdaBasicExecutionRole](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.aws_xray_write_only_access](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.uuid_app](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.uuid_app](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/kms_key) | resource |
| [aws_lambda_function.calc](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/lambda_function) | resource |
| [aws_s3_bucket.uuid_app](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.example_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_public_access_block.non-public](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.uuid_app](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [github_repository_webhook.github_hook](https://registry.terraform.io/providers/hashicorp/github/latest/docs/resources/repository_webhook) | resource |
| [random_string.github_secret](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |
| [random_string.random_name](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |
| [archive_file.lambda_payload](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.AWSLambdaBasicExecutionRole](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.AWSLambdaRole](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.cloudformation_inline_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_inline_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cognito_ses_notifications](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inline_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.uuid_app_cb_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.uuid_app_cf_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.uuid_app_cp_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/region) | data source |
| [template_file.buildspec](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | n/a | `string` | `"warnacle"` | no |
| <a name="input_deployment_role"></a> [deployment\_role](#input\_deployment\_role) | n/a | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | n/a | `string` | `"dev"` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | n/a | <pre>object({<br>    branch          = string<br>    owner           = string<br>    name            = string<br>    poll_for_change = bool<br>  })</pre> | <pre>{<br>  "branch": "master",<br>  "name": "aws-devtools-pipeline",<br>  "owner": "ajorpheus",<br>  "poll_for_change": true<br>}</pre> | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | Github Personal Access Token | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apigw_invoke_url_full"></a> [apigw\_invoke\_url\_full](#output\_apigw\_invoke\_url\_full) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
