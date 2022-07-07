# AWS Developer Tools Pipeline

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![checkov](https://img.shields.io/badge/checkov-verified-brightgreen)](https://www.checkov.io/)

<!-- vim-markdown-toc GFM -->

* [Description](#description)
    * [1. BootStrap ( bootstrap-aws-role dir)](#1-bootstrap--bootstrap-aws-role-dir)
    * [2. Github Actions CI Job](#2-github-actions-ci-job)
    * [3. Main Terraform ( terraform dir)](#3-main-terraform--terraform-dir)
    * [4. Serverless API (Flask App) ( wrncl-uuid-api dir)](#4-serverless-api-flask-app--wrncl-uuid-api-dir)
* [Usage](#usage)
    * [1. Execute bootstrap](#1-execute-bootstrap)
    * [2. Execute Github Actions CI job](#2-execute-github-actions-ci-job)
        * [Using Github CLI](#using-github-cli)
        * [Manually](#manually)

<!-- vim-markdown-toc -->

## Description

This repository provisions a CI pipeline using AWS Developer Tools (AWS Codepipeline, CodeBuild and CodeDeploy) which is triggered by changes to this repository. This CI pipeline is responsible for deploying or updating a Serverless UUID-JobName App (#4).

This repository is composed of the following parts.

### 1. BootStrap ( [bootstrap-aws-role](bootstrap-aws-role) dir)

Bootstrap contains scripts to create account level resources (for instance, Cloudwatch group for APIGW logging for the whole region), but most crucially it provisions the Github OIDC provider in the AWS account to allow Github Actions workflow in this repository to access AWS Resources.

This allows the Github Actions workflow to execute without the need to configure long lived AWS secrets in the repository itself.

### 2. Github Actions Workflow [CI Job](.github/workflows/main.yml)

This is responsible for executing the Terraform scripts in (#3) `terraform` dir. This is the 'parent' CI job that actually creates the AWS Codepipeline resources in AWS. Authentication to AWS is performed using Github OIDC provider created by the bootstrap, as mentioned above.

This will only be triggered by a `push` to master and only if the pushed commit contains changes to `terraform/*.tf`

The Terraform execution to create the above resources is performed by a Github Actions CI

Besides executing terraform, the GHA CI job also performs linting, static analysis (**tflint**), security scanning (**checkov**, **tfsec**)

Terraform remote state management and provisioning is delegated to **Terragrunt**

### 3. Main Terraform ( [terraform](terraform) dir)

Contains the Terraform configuration to provision the AWS Developer Tools resources. This configuration is applied by the Github Actions CI job.

### 4. Serverless API (Flask App) ( [wrncl-uuid-api](wrncl-uuid-api) dir)

Contains an AWS SAM application with the following APIs:

| Request               | Response | Comment                                     |
|-----------------------|----------|---------------------------------------------|
| POST /job/name/{name} | HTTP 200 | Creates a UUID for `{name}` in DynamoDB     |
| GET /job/name/{name}  | UUID     | Returns the UUID for `{name}` in DynamoDB   |
| GET /job/name/{name}  | JOB NAME | Returns the job-name for the given `{uuid}` |

## Usage

### 1. Execute bootstrap

Head over to the boostrap readme and follow the instructions there : [bootstrap-aws-role/README.md](bootstrap-aws-role/README.md)

This needs to be done only once to configure this github repository with the secrets used by the Github Actions Pipeline.

### 2. Execute Github Actions CI job

#### Using Github CLI

If you have [Github CLI](https://github.com/cli/cli#github-cli) :

```bash
gh workflow run main.yml
```

#### Manually

On Github:

1. Navigate to repository -> Actions -> 'Terraform CI Job'
1. Click on 'Run Workflow' drop down -> Branch: master -> Click 'Run Workflow' button
