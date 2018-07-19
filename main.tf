provider "aws" {
  region = "us-west-2"
  profile = "lab"
}

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  role        = "${aws_iam_role.example.name}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-us-west-2-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion"
            ]
        }
    ]
}
POLICY
}

resource "aws_codebuild_project" "project" {
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/golang:1.10"
    type         = "LINUX_CONTAINER"
  }

  name = "test_github_pr_project"
  badge_enabled = true

  source {
    type            = "GITHUB"
    location        = "https://github.com/gibbster/codebuild-pr-test.git"
    git_clone_depth = 1
  }

  service_role = "${aws_iam_role.example.arn}"
}

resource "aws_codebuild_webhook" "example" {
  project_name = "${aws_codebuild_project.project.name}"
}

