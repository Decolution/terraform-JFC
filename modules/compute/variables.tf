# ============================================
# VARIABLES - COMPUTE MODULE
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
  description = "IDs de las subnets privadas (para ECS Fargate)"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs de las subnets públicas (para ALB)"
  type        = list(string)
}

variable "ecs_tasks_min" {
  description = "Número mínimo de tareas ECS por servicio"
  type        = number
  default     = 3
}

variable "ecs_tasks_max" {
  description = "Número máximo de tareas ECS por servicio"
  type        = number
  default     = 6
}

variable "ecs_cpu" {
  description = "vCPU por tarea ECS"
  type        = number
  default     = 1024
}

variable "ecs_memory" {
  description = "Memoria por tarea ECS (MB)"
  type        = number
  default     = 2048
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}