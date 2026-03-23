# ============================================
# COMPUTE MODULE - ALB, ECS FARGATE, AUTO SCALING
# ============================================

# ============================================
# 1. APPLICATION LOAD BALANCER (ALB)
# ============================================

# Security Group para ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })
}

# ALB
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

# Target Group para Orders Service
resource "aws_lb_target_group" "orders" {
  name        = "${var.project_name}-${var.environment}-orders-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/health"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-orders-tg"
    Service = "orders"
  })
}

# Target Group para Payments Service
resource "aws_lb_target_group" "payments" {
  name        = "${var.project_name}-${var.environment}-payments-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/health"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-payments-tg"
    Service = "payments"
  })
}

# Target Group para Inventory Service
resource "aws_lb_target_group" "inventory" {
  name        = "${var.project_name}-${var.environment}-inventory-tg"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/health"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-inventory-tg"
    Service = "inventory"
  })
}

# Target Group para Users Service
resource "aws_lb_target_group" "users" {
  name        = "${var.project_name}-${var.environment}-users-tg"
  port        = 8083
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/health"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-users-tg"
    Service = "users"
  })
}

# Listener HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Listener HTTP (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Rules para path-based routing
resource "aws_lb_listener_rule" "orders" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }

  condition {
    path_pattern {
      values = ["/orders/*", "/orders"]
    }
  }
}

resource "aws_lb_listener_rule" "payments" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payments.arn
  }

  condition {
    path_pattern {
      values = ["/payments/*", "/payments"]
    }
  }
}

resource "aws_lb_listener_rule" "inventory" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inventory.arn
  }

  condition {
    path_pattern {
      values = ["/inventory/*", "/inventory"]
    }
  }
}

resource "aws_lb_listener_rule" "users" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 130

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.users.arn
  }

  condition {
    path_pattern {
      values = ["/users/*", "/users"]
    }
  }
}

# Data source para ACM certificate
data "aws_acm_certificate" "main" {
  domain   = "*.${var.project_name}.com"
  statuses = ["ISSUED"]
}

# ============================================
# 2. ECS CLUSTER
# ============================================

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-cluster"
  })
}

# ============================================
# 3. ECS TASK DEFINITION (Orders Service)
# ============================================

resource "aws_ecs_task_definition" "orders" {
  family                   = "${var.project_name}-${var.environment}-orders"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "orders"
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.project_name}-${var.environment}-orders:latest"
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://aurora-cluster-endpoint:5432/ecommerce"
        },
        {
          name  = "REDIS_URL"
          value = "redis://redis-cluster-endpoint:6379"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-orders"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-orders-task"
  })
}

# ============================================
# 4. ECS SERVICE (Orders)
# ============================================

resource "aws_ecs_service" "orders" {
  name            = "${var.project_name}-${var.environment}-orders"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = var.ecs_tasks_min
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.orders.arn
    container_name   = "orders"
    container_port   = 8080
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_minimum_healthy_percent = 66
  deployment_maximum_percent         = 200

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-orders-service"
  })
}

# ============================================
# 5. AUTO SCALING
# ============================================

resource "aws_appautoscaling_target" "orders" {
  max_capacity       = var.ecs_tasks_max
  min_capacity       = var.ecs_tasks_min
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.orders.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "orders_cpu" {
  name               = "${var.project_name}-${var.environment}-orders-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.orders.resource_id
  scalable_dimension = aws_appautoscaling_target.orders.scalable_dimension
  service_namespace  = aws_appautoscaling_target.orders.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ============================================
# 6. IAM ROLES
# ============================================

resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Policy para acceder a Secrets Manager
resource "aws_iam_role_policy" "ecs_task_secrets" {
  name = "${var.project_name}-${var.environment}-ecs-task-secrets-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-${var.environment}-*"
        ]
      }
    ]
  })
}

# ============================================
# 7. SECURITY GROUP PARA ECS
# ============================================

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
  })
}

# ============================================
# 8. DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}