# ============================================
# OUTPUTS DE REDES (VPC)
# ============================================

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas (ECS Fargate)"
  value       = module.networking.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "IDs de las subnets aisladas (Aurora, Redis)"
  value       = module.networking.isolated_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name del Application Load Balancer"
  value       = module.compute.alb_dns_name
}

# ============================================
# OUTPUTS DE SEGURIDAD
# ============================================

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = module.security.cognito_user_pool_id
}

output "cognito_app_client_id" {
  description = "ID del App Client de Cognito"
  value       = module.security.cognito_app_client_id
}

output "waf_web_acl_id" {
  description = "ID del Web ACL de WAF"
  value       = module.security.waf_web_acl_id
}

# ============================================
# OUTPUTS DE COMPUTO (ECS Fargate)
# ============================================

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = module.compute.ecs_cluster_name
}

output "ecs_service_names" {
  description = "Nombres de los servicios ECS"
  value       = module.compute.ecs_service_names
}

output "ecs_task_role_arn" {
  description = "ARN del rol IAM para tareas ECS"
  value       = module.compute.ecs_task_role_arn
}

# ============================================
# OUTPUTS DE BASES DE DATOS
# ============================================

output "aurora_cluster_endpoint" {
  description = "Endpoint del cluster Aurora (escrituras)"
  value       = module.database.aurora_cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Endpoint de lectura de Aurora (lecturas)"
  value       = module.database.aurora_reader_endpoint
}

output "dynamodb_tables" {
  description = "Nombres de las tablas DynamoDB"
  value       = module.database.dynamodb_tables
}

output "redis_cluster_endpoint" {
  description = "Endpoint del cluster Redis (ElastiCache)"
  value       = module.database.redis_cluster_endpoint
}

# ============================================
# OUTPUTS DE ALMACENAMIENTO (S3)
# ============================================

output "frontend_bucket_name" {
  description = "Nombre del bucket S3 para frontend"
  value       = module.storage.frontend_bucket_name
}

output "frontend_bucket_arn" {
  description = "ARN del bucket S3 para frontend"
  value       = module.storage.frontend_bucket_arn
}

output "media_bucket_name" {
  description = "Nombre del bucket S3 para assets multimedia"
  value       = module.storage.media_bucket_name
}

output "media_bucket_arn" {
  description = "ARN del bucket S3 para assets multimedia"
  value       = module.storage.media_bucket_arn
}

# ============================================
# OUTPUTS DE OBSERVABILIDAD
# ============================================

output "cloudwatch_log_group_names" {
  description = "Nombres de los grupos de logs de CloudWatch"
  value       = module.observability.cloudwatch_log_group_names
}

output "sns_topic_arn" {
  description = "ARN del topic SNS para alertas"
  value       = module.observability.sns_topic_arn
}

# ============================================
# OUTPUTS DE CI/CD (ECR)
# ============================================

output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR"
  value       = module.ci_cd.ecr_repository_urls
}