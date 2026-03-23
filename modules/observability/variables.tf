# ============================================
# VARIABLES - OBSERVABILITY MODULE
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
}

variable "alb_arn" {
  description = "ARN del Application Load Balancer"
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
  default     = ""
}

variable "aurora_arn" {
  description = "ARN del cluster Aurora"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}