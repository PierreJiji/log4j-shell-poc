#-------------------------------------------------------------------------------
# IAM
data "aws_iam_policy_document" "ecs_task_execution_role_policy_doc" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
} 

resource "aws_iam_policy" "policy" {
  name        = "${local.name}-EcsTaskExecPolicy"
  description = "A ecs task policy"
  policy      =  <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ssm:GetParameters",
                "secretsmanager:GetSecretValue",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name  = "${local.name}-EcsTaskExecRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy_doc.json
  path               = "/${var.aws_ecs_application}/${var.aws_ecs_environment}/"
}

resource "aws_iam_policy_attachment" "Ecs-policy-attach" {
  name       = "${local.name}-EcsTaskExecAttachement"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.policy.arn
}