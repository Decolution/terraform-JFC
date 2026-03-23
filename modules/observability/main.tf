# ============================================
# OBSERVABILITY MODULE - CLOUDWATCH, X-RAY, SNS, GRAFANA
# ============================================

# ============================================
# 1. CLOUDWATCH LOG GROUPS
# ============================================

# Log group para ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-logs"
  })
}

# Log group para Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-lambda-logs"
  })
}

# Log group para VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/vpc/${var.project_name}-${var.environment}-flow-logs"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  })
}

# ============================================
# 2. CLOUDWATCH DASHBOARDS
# ============================================

# Dashboard de Operaciones
resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = "${var.project_name}-${var.environment}-operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ALB Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { service = "${var.ecs_cluster_name}", stat = "Average" }],
            ["AWS/ECS", "MemoryUtilization", { service = "${var.ecs_cluster_name}", stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", { DBClusterIdentifier = "aurora" }],
            ["AWS/RDS", "CPUUtilization", { DBClusterIdentifier = "aurora" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Aurora Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/DynamoDB", "SuccessfulRequestLatency", { TableName = "products" }],
            ["AWS/DynamoDB", "ThrottledRequests", { TableName = "products" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "DynamoDB Metrics"
        }
      }
    ]
  })
}

# Dashboard de Negocios
resource "aws_cloudwatch_dashboard" "business" {
  dashboard_name = "${var.project_name}-${var.environment}-business"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["CustomNamespace", "OrdersCreated", { stat = "Sum" }],
            ["CustomNamespace", "Revenue", { stat = "Sum" }],
            ["CustomNamespace", "ActiveUsers", { stat = "Average" }]
          ]
          period = 3600
          stat   = "Sum"
          region = "us-east-1"
          title  = "Business Metrics"
        }
      }
    ]
  })
}

# ============================================
# 3. CLOUDWATCH ALARMS
# ============================================

# Alarma: ALB 5XX errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB 5XX errors exceed threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn
  }

  tags = var.tags
}

# Alarma: ECS CPU alta
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS CPU utilization > 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }

  tags = var.tags
}

# Alarma: ECS memoria alta
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "ECS Memory utilization > 85%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }

  tags = var.tags
}

# Alarma: Aurora conexiones altas
resource "aws_cloudwatch_metric_alarm" "aurora_connections" {
  alarm_name          = "${var.project_name}-${var.environment}-aurora-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Aurora connections > 100"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBClusterIdentifier = var.aurora_arn
  }

  tags = var.tags
}

# ============================================
# 4. SNS TOPIC (Alertas)
# ============================================

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
  })
}

# Suscripción por Email
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "alerts@${var.project_name}.com"
}

# Suscripción por Slack (opcional, requiere webhook)
# resource "aws_sns_topic_subscription" "slack" {
#   topic_arn = aws_sns_topic.alerts.arn
#   protocol  = "https"
#   endpoint  = "https://hooks.slack.com/services/XXX/XXX/XXX"
# }

# ============================================
# 5. AWS X-RAY
# ============================================

# X-Ray no requiere recursos específicos, solo habilitar en servicios
# X-Ray tracing se configura en Lambda y ECS

# ============================================
# 6. AMAZON MANAGED GRAFANA (Opcional)
# ============================================

resource "aws_grafana_workspace" "main" {
  count = var.environment == "prod" ? 1 : 0

  name                     = "${var.project_name}-${var.environment}-grafana"
  description              = "Grafana workspace for JFC e-commerce"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana[0].arn

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-grafana"
  })
}

# IAM Role para Grafana
resource "aws_iam_role" "grafana" {
  count = var.environment == "prod" ? 1 : 0

  name = "${var.project_name}-${var.environment}-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Política para Grafana (acceso a CloudWatch)
resource "aws_iam_role_policy_attachment" "grafana" {
  count = var.environment == "prod" ? 1 : 0

  role       = aws_iam_role.grafana[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# ============================================
# 7. CLOUDTRAIL (Auditoría)
# ============================================

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = "${var.project_name}-${var.environment}-logs"
  include_global_service_events = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-trail"
  })
}