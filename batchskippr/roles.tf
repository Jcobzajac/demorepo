data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "instance_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "skippr_ingest" {
  name        = "skippr-ingest-policy"
  description = "Policy for Skippr Ingest Role"
  
  # The policy document for Skippr Ingest Role
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow",
        Action = ["s3:ListBuckets"],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:ListObjectsV2",
          "s3:ListObjects",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "athena:*",
          "glue:*"
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:*",
          "ssm:GetParameters"
        ],
        Resource = ["*"]
      },
      # Optional secret for API key
      # Conditionally include this statement
      var.include_optional_statement ? <<EOF
      ,
      {
        Effect = "Allow",
        Action = ["secretsmanager:*"],
        Resource = ["${var.skippr_api_key_secret_arn}"]
      }
      EOF
      : ""
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment_instance_role" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.skippr_ingest.arn
}

resource "aws_iam_instance_profile" "skippr_instance_role" {
  name = "skippr_instance_role"
  role = aws_iam_role.instance_role.name
}

#Batch service role for operations on the behalf of the service

data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws_batch_service_role"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}