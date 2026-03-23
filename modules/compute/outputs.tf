# ============================================
# OUTPUTS - COMPUTE MODULE
# ============================================

output "alb_id" {
  description = "ID del Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "ecs_cluster_id" {
  description = "ID del cluster ECS"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_names" {
  description = "Nombres de los servicios ECS"
  value = {
    orders = aws_ecs_service.orders.name
    # payments  = aws_ecs_service.payments.name
    # inventory = aws_ecs_service.inventory.name
    # users     = aws_ecs_service.users.name
  }
}

output "ecs_task_role_arn" {
  description = "ARN del rol IAM para tareas ECS"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_execution_role_arn" {
  description = "ARN del rol IAM para ejecución ECS"
  value       = aws_iam_role.ecs_execution.arn
}

output "target_group_arns" {
  description = "ARNs de los Target Groups"
  value = {
    orders    = aws_lb_target_group.orders.arn
    payments  = aws_lb_target_group.payments.arn
    inventory = aws_lb_target_group.inventory.arn
    users     = aws_lb_target_group.users.arn
  }
}