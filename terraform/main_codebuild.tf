data "template_file" "buildspec" {
  template = file("../wrncl-uuid-api/buildspec.yml")
  vars = {
    env = var.environment_name
  }
}

resource "aws_codebuild_project" "uuid_app" {
  name = "uuid_app"

  badge_enabled  = false
  build_timeout  = 60
  queued_timeout = 480
  service_role   = aws_iam_role.uuid_app_cb.arn

  artifacts {
    encryption_disabled    = false
    name                   = "uuid_app-${var.environment_name}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  tags = module.root_tags.tags
}
