# ============================================
# OUTPUTS - DATABASE MODULE
# ============================================

# Aurora outputs
output "aurora_cluster_id" {
  description = "ID del cluster Aurora"
  value       = aws_rds_cluster.aurora.id
}

output "aurora_cluster_arn" {
  description = "ARN del cluster Aurora"
  value       = aws_rds_cluster.aurora.arn
}

output "aurora_cluster_endpoint" {
  description = "Endpoint del cluster Aurora (escrituras)"
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_reader_endpoint" {
  description = "Endpoint de lectura de Aurora"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "aurora_master_username" {
  description = "Username master de Aurora"
  value       = aws_rds_cluster.aurora.master_username
  sensitive   = true
}

# DynamoDB outputs
output "dynamodb_tables" {
  description = "Nombres de las tablas DynamoDB"
  value = {
    products        = aws_dynamodb_table.products.name
    carts           = aws_dynamodb_table.carts.name
    sessions        = aws_dynamodb_table.sessions.name
    inventory_cache = aws_dynamodb_table.inventory_cache.name
  }
}

output "dynamodb_table_arns" {
  description = "ARNs de las tablas DynamoDB"
  value = {
    products        = aws_dynamodb_table.products.arn
    carts           = aws_dynamodb_table.carts.arn
    sessions        = aws_dynamodb_table.sessions.arn
    inventory_cache = aws_dynamodb_table.inventory_cache.arn
  }
}

# Redis outputs
output "redis_cluster_id" {
  description = "ID del cluster Redis"
  value       = aws_elasticache_replication_group.redis.id
}

output "redis_cluster_endpoint" {
  description = "Endpoint del cluster Redis (escrituras)"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Endpoint de lectura de Redis"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Puerto de Redis"
  value       = aws_elasticache_replication_group.redis.port
}

# Security Groups outputs
output "aurora_security_group_id" {
  description = "ID del Security Group de Aurora"
  value       = aws_security_group.aurora.id
}

output "redis_security_group_id" {
  description = "ID del Security Group de Redis"
  value       = aws_security_group.redis.id
}

output "ecs_database_security_group_id" {
  description = "ID del Security Group de ECS para bases de datos"
  value       = aws_security_group.ecs.id
}

# RDS Proxy output
output "rds_proxy_endpoint" {
  description = "Endpoint del RDS Proxy"
  value       = aws_db_proxy.aurora.endpoint
}

# Secrets Manager output
output "aurora_secret_arn" {
  description = "ARN del secreto de Aurora"
  value       = aws_secretsmanager_secret.aurora_credentials.arn
}