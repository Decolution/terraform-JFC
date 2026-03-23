# ============================================
# VARIABLES GLOBALES
# ============================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "jfc-ecommerce"
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

# ============================================
# VARIABLES DE REDES (VPC)
# ============================================

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "availability_zones" {
  description = "Lista de Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para subnets públicas"
  type        = list(string)
  default     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks para subnets privadas (ECS Fargate)"
  type        = list(string)
  default     = ["172.16.10.0/24", "172.16.11.0/24", "172.16.12.0/24"]
}

variable "isolated_subnet_cidrs" {
  description = "CIDR blocks para subnets aisladas (Aurora, Redis)"
  type        = list(string)
  default     = ["172.16.20.0/24", "172.16.21.0/24", "172.16.22.0/24"]
}

# ============================================
# VARIABLES DE COMPUTO (ECS Fargate)
# ============================================

variable "ecs_tasks_min" {
  description = "Número mínimo de tareas ECS por servicio"
  type        = number
  default     = 3 # 1 por AZ
}

variable "ecs_tasks_max" {
  description = "Número máximo de tareas ECS por servicio"
  type        = number
  default     = 6 # 2 por AZ
}

variable "ecs_cpu" {
  description = "vCPU por tarea ECS"
  type        = number
  default     = 1024 # 1 vCPU
}

variable "ecs_memory" {
  description = "Memoria por tarea ECS (MB)"
  type        = number
  default     = 2048 # 2 GB
}

# ============================================
# VARIABLES DE BASE DE DATOS
# ============================================

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

# ============================================
# VARIABLES DE DOMINIO Y CERTIFICADOS
# ============================================

variable "domain_name" {
  description = "Nombre de dominio principal"
  type        = string
  default     = "ecommerce.jfc.com"
}

# ============================================
# VARIABLES DE ETIQUETAS (TAGS)
# ============================================

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "jfc-ecommerce"
    ManagedBy   = "Terraform"
  }
}