### State Locking

terraform {
  backend "s3" {
    bucket         = "product-hunting-terraform-state"
    key            = "review/deploy/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

### Add VPC

data "aws_vpc" "product-hunting-vpc" {
  filter {
    name   = "tag:Name"
    values = ["product-hunting-vpc"]
  }
}

data "aws_subnets" "product-hunting-subnets" {
  filter {
    name = "tag:Name"
    values = [
      "product-hunting-subnet-public-1",
      "product-hunting-subnet-public-2"
    ]
  }
}

### Add AWS Certificate Manager certificate

data "aws_acm_certificate" "product-hunting-acm-certificate" {
  domain   = "devops-product-hunting.com"
  statuses = ["ISSUED"]
}

### Security groups

resource "aws_security_group" "product-hunting-sg-lb" {
  name   = "product-hunting-sg-lb"
  vpc_id = data.aws_vpc.product-hunting-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "product-hunting-sg-ecs" {
  name   = "product-hunting-sg-ecs"
  vpc_id = data.aws_vpc.product-hunting-vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      aws_security_group.product-hunting-sg-lb.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Load Balancer for ECS

resource "aws_lb" "product-hunting-lb" {
  name               = "product-hunting-lb"
  load_balancer_type = "application"
  subnets = [
    data.aws_subnets.product-hunting-subnets.ids[0],
    data.aws_subnets.product-hunting-subnets.ids[1]
  ]
  security_groups = [
    aws_security_group.product-hunting-sg-lb.id
  ]
}

resource "aws_lb_target_group" "product-hunting-lb-target-group-http" {
  name        = "product-hunting-tg-http"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.product-hunting-vpc.id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "10"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302" ### 301 & 302 => Redirect
    path                = "/"
  }
}

resource "aws_lb_target_group" "product-hunting-lb-target-group-https" {
  name        = "product-hunting-tg-https"
  target_type = "ip"
  port        = 443
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.product-hunting-vpc.id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "10"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
  }
}

resource "aws_lb_target_group" "product-hunting-lb-target-group-api" {
  name        = "product-hunting-tg-api"
  target_type = "ip"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.product-hunting-vpc.id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "30"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/posts/1"
  }
}

resource "aws_lb_listener" "product-hunting-lb-listener-http" {
  load_balancer_arn = aws_lb.product-hunting-lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.product-hunting-lb-target-group-http.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "product-hunting-lb-listener-https" {
  load_balancer_arn = aws_lb.product-hunting-lb.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.product-hunting-acm-certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.product-hunting-lb-target-group-https.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "product-hunting-lb-listener-api" {
  load_balancer_arn = aws_lb.product-hunting-lb.id
  port              = 5000
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.product-hunting-acm-certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.product-hunting-lb-target-group-api.id
    type             = "forward"
  }
}

### ECS Resources

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
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "product-hunting-policy-ecs-exec" {
  name = "ProductHuntingECSExecPolicy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
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
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = data.aws_iam_role.product-hunting-ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.product-hunting-role-ecs-exec.arn

  container_definitions = jsonencode([
    {
      name      = "product-hunting-postgres"
      image     = "${var.ecr_registry}/product-hunting-postgres:review"
      cpu       = 512
      memory    = 1536
      essential = true
    },
    {
      name      = "product-hunting-api"
      image     = "${var.ecr_registry}/product-hunting-api:review"
      cpu       = 256
      memory    = 1024
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
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        },
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  depends_on = [aws_iam_role_policy_attachment.product-hunting-ProductHuntingECSExecPolicy]
}

resource "aws_ecs_service" "product-hunting-ecs-service" {
  name                   = "product-hunting-ecs-service"
  cluster                = aws_ecs_cluster.product-hunting-ecs-cluster.id
  task_definition        = aws_ecs_task_definition.product-hunting-ecs-td.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true
  network_configuration {
    subnets = [
      data.aws_subnets.product-hunting-subnets.ids[0],
      data.aws_subnets.product-hunting-subnets.ids[1]
    ]
    security_groups  = [aws_security_group.product-hunting-sg-ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.product-hunting-lb-target-group-http.arn
    container_name   = "product-hunting-client"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.product-hunting-lb-target-group-https.arn
    container_name   = "product-hunting-client"
    container_port   = 443
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.product-hunting-lb-target-group-api.arn
    container_name   = "product-hunting-api"
    container_port   = 5000
  }
}

### Route 53 Zone record

data "aws_route53_zone" "product-hunting-route53-zone" {
  name         = "devops-product-hunting.com."
  private_zone = false
}

resource "aws_route53_record" "product-hunting-route53-record" {
  zone_id = data.aws_route53_zone.product-hunting-route53-zone.zone_id
  name    = "review.devops-product-hunting.com"
  type    = "A"

  alias {
    name                   = aws_lb.product-hunting-lb.dns_name
    zone_id                = aws_lb.product-hunting-lb.zone_id
    evaluate_target_health = true
  }
}
