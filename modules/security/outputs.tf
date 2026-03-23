# ============================================
# OUTPUTS - SECURITY MODULE
# ============================================

output "ecs_security_group_id" {
  description = "ID del Security Group para ECS Fargate"
  value       = aws_security_group.ecs.id
}

output "aurora_security_group_id" {
  description = "ID del Security Group para Aurora"
  value       = aws_security_group.aurora.id
}

output "redis_security_group_id" {
  description = "ID del Security Group para Redis"
  value       = aws_security_group.redis.id
}

output "alb_security_group_id" {
  description = "ID del Security Group para ALB"
  value       = var.alb_security_group_id != "" ? var.alb_security_group_id : aws_security_group.alb[0].id
}

output "waf_web_acl_id" {
  description = "ID del Web ACL de WAF"
  value       = aws_wafv2_web_acl.main.id
}

output "waf_web_acl_arn" {
  description = "ARN del Web ACL de WAF"
  value       = aws_wafv2_web_acl.main.arn
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_app_client_id" {
  description = "ID del App Client de Cognito"
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_domain" {
  description = "Dominio de Cognito"
  value       = try(aws_cognito_user_pool_domain.main[0].domain, null)
}