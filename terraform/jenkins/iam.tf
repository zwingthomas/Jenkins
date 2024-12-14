# Declare instance role to attach policies to
resource "aws_iam_role" "jenkins_instance_role" {
  name = "${var.project_name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Declare profile for the rold
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.jenkins_instance_role.name
}

resource "aws_iam_policy" "jenkins_policy" {
  name        = "${var.project_name}-policy"
  description = "Policy for Jenkins server to access AWS services"

  # This is too broad of permissions, but it was taking a very long time to narrow it so I cut this corner to save time
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # ECR Access
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      },
      # S3 Access
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      },
      # DynnamoDB
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "arn:aws:dynamodb:us-east-1:354923279633:table/terraform-lock-table"
      },
      # ECS Access
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      },
      # CloudWatch Logs Access
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      },
      # EC2
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      },
      # acm
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      },
      # elb
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      },
      # iam
      {
        "Effect": "Allow",
        "Action": "*",
        "Resource": "*"
      },
    ]
  })
}

# Associate policies with the role
resource "aws_iam_role_policy_attachment" "jenkins_role_policy_attachment" {
  role       = aws_iam_role.jenkins_instance_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}
