#data "aws_vpc" "selected" {
  #id = var.vpc_id
#}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_security_group" "skippr-sg" {
  name = "Skippr security group" 

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from Skippr.io"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_placement_group" "sample" {
  name     = "sample"
  strategy = "cluster"
}

resource "aws_batch_compute_environment" "sample" {
  compute_environment_name = "skippr-io-batch-environment"

  compute_resources {
    instance_role = aws_iam_instance_profile.skippr_instance_role.arn

    instance_type = [
      "c4.large",
    ]

    max_vcpus = 16
    min_vcpus = 0

    placement_group = aws_placement_group.sample.name

    security_group_ids = [
      aws_security_group.skippr-sg.id,
    ]

    subnets = data.aws_subnets.private.ids


    type = "EC2"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED" 
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]
}



#TAGS