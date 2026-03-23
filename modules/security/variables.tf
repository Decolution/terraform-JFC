# ============================================
# VARIABLES - SECURITY MODULE
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

variable "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Nombre de dominio principal"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}