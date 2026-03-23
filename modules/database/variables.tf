# ============================================
# VARIABLES - DATABASE MODULE
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

variable "isolated_subnet_ids" {
  description = "IDs de las subnets aisladas (para Aurora y Redis)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  type        = list(string)
}

variable "aurora_min_capacity" {
  description = "Capacidad mínima de Aurora Serverless v2 (ACU)"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Capacidad máxima de Aurora Serverless v2 (ACU)"
  type        = number
  default     = 4
}

variable "redis_node_type" {
  description = "Tipo de nodo para ElastiCache Redis"
  type        = string
  default     = "cache.t3.medium"
}

variable "redis_num_nodes" {
  description = "Número de nodos Redis (1 primary + N replicas)"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}