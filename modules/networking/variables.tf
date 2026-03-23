# ============================================
# VARIABLES - NETWORKING MODULE
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

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "jfc-ecommerce"
    ManagedBy   = "Terraform"
  }
}