# ============================================
# VARIABLES - API MODULE
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  type        = list(string)
  default     = []
}

variable "alb_dns_name" {
  description = "DNS name del ALB (para enrutar tráfico complejo)"
  type        = string
  default     = ""
}

variable "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  type        = string
  default     = ""
}

variable "dynamodb_tables" {
  description = "Mapa de tablas DynamoDB"
  type        = map(string)
  default     = {}
}

variable "redis_endpoint" {
  description = "Endpoint del cluster Redis"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}