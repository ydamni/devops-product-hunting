### State Locking

terraform {
  backend "s3" {
    bucket = "product-hunting-terraform-state"
    key    = "review/deploy/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

### Add VPC

data "aws_subnets" "product-hunting-aws-subnets" {
  filter {
    name   = "tag:Name"
    values = ["product-hunting-subnet-public-1", "product-hunting-subnet-public-2"]
  }
}

data "aws_security_groups" "product-hunting-aws-sg" {
  filter {
    name   = "tag:Name"
    values = ["product-hunting-sg-allow-http", "product-hunting-sg-allow-api"]
  }
}

### ECS resources

resource "aws_ecs_cluster" "product-hunting-ecs-cluster" {
  name = "product-hunting-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "product-hunting-ecs-provider" {
  cluster_name       = aws_ecs_cluster.product-hunting-ecs-cluster.name
  capacity_providers = ["FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}

data "aws_iam_role" "product-hunting-ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role" "product-hunting-role-ecs-exec" {
  name = "product-hunting-role-ecs-exec"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy" "product-hunting-policy-ecs-exec" {
  name = "ProductHuntingECSExecPolicy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "product-hunting-ProductHuntingECSExecPolicy" {
  policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/ProductHuntingECSExecPolicy"
  role       = aws_iam_role.product-hunting-role-ecs-exec.name

  depends_on = [aws_iam_role.product-hunting-role-ecs-exec, aws_iam_policy.product-hunting-policy-ecs-exec]
}

resource "aws_ecs_task_definition" "product-hunting-ecs-td" {
  family                   = "product-hunting-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.product-hunting-ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.product-hunting-role-ecs-exec.arn

  container_definitions = jsonencode([
    {
      name      = "product-hunting-postgres"
      image     = "${var.ecr_registry}/product-hunting-postgres:review"
      cpu       = 256
      memory    = 512
      essential = true
    },
    {
      name      = "product-hunting-api"
      image     = "${var.ecr_registry}/product-hunting-api:review"
      cpu       = 128
      memory    = 256
      essential = true
      environment = [
        {
          name  = "POSTGRES_HOST"
          value = "localhost"
        }
      ]
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    },
    {
      name      = "product-hunting-client"
      image     = "${var.ecr_registry}/product-hunting-client:review"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  depends_on = [aws_iam_role_policy_attachment.product-hunting-ProductHuntingECSExecPolicy]
}

resource "aws_ecs_service" "product-hunting-ecs-service" {
  name            = "product-hunting-ecs-service"
  cluster         = aws_ecs_cluster.product-hunting-ecs-cluster.id
  task_definition = aws_ecs_task_definition.product-hunting-ecs-td.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true
  network_configuration {
    subnets          = [data.aws_subnets.product-hunting-aws-subnets.ids[0], data.aws_subnets.product-hunting-aws-subnets.ids[1]]
    security_groups  = [data.aws_security_groups.product-hunting-aws-sg.ids[0], data.aws_security_groups.product-hunting-aws-sg.ids[1]]
    assign_public_ip = true
  }
}

### Route 53 Zone record

### Wait for ENI to link with Fargate Task
resource "time_sleep" "wait_60_seconds" {
  depends_on = [aws_ecs_service.product-hunting-ecs-service]

  create_duration = "60s"
}

data "aws_network_interface" "product-hunting-eni" {
  filter {
    name = "group-id"
    values = [data.aws_security_groups.product-hunting-aws-sg.ids[0], data.aws_security_groups.product-hunting-aws-sg.ids[1]]
  }
  depends_on = [time_sleep.wait_60_seconds]
}

data "aws_route53_zone" "product-hunting-aws-route53-zone" {
  name         = "devops-product-hunting.com."
  private_zone = false
}

resource "aws_route53_record" "product-hunting-aws-route53-record" {
  zone_id = data.aws_route53_zone.product-hunting-aws-route53-zone.zone_id
  name    = "review.devops-product-hunting.com"
  type    = "A"
  ttl     = "300"
  records = [data.aws_network_interface.product-hunting-eni.association[0].public_ip]
}
