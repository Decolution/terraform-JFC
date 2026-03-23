# ============================================
# OUTPUTS - OBSERVABILITY MODULE
# ============================================

output "cloudwatch_log_groups" {
  description = "Nombres de los grupos de logs"
  value = {
    ecs      = aws_cloudwatch_log_group.ecs.name
    lambda   = aws_cloudwatch_log_group.lambda.name
    vpc_flow = aws_cloudwatch_log_group.vpc_flow.name
  }
}

output "cloudwatch_dashboards" {
  description = "Nombres de los dashboards"
  value = {
    operations = aws_cloudwatch_dashboard.operations.dashboard_name
    business   = aws_cloudwatch_dashboard.business.dashboard_name
  }
}

output "sns_topic_arn" {
  description = "ARN del topic SNS para alertas"
  value       = aws_sns_topic.alerts.arn
}

output "grafana_workspace_id" {
  description = "ID del workspace de Grafana"
  value       = try(aws_grafana_workspace.main[0].id, null)
}

output "grafana_workspace_endpoint" {
  description = "Endpoint del workspace de Grafana"
  value       = try(aws_grafana_workspace.main[0].endpoint, null)
}

output "cloudtrail_id" {
  description = "ID del CloudTrail"
  value       = aws_cloudtrail.main.id
}