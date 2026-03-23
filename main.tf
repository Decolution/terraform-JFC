# ============================================
# MAIN.TF - JFC E-COMMERCE INFRASTRUCTURE
# ============================================
# Este archivo orquesta todos los módulos de la arquitectura
# ============================================

# ============================================
# 1. MÓDULO DE REDES (VPC, SUBNETS, NAT, IGW)
# ============================================
module "networking" {
  source = "./modules/networking"

  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs

  tags = var.tags
}

# ============================================
# 2. MÓDULO DE SEGURIDAD (WAF, COGNITO, SECURITY GROUPS)
# ============================================
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  domain_name  = var.domain_name

  tags = var.tags
}

# ============================================
# 3. MÓDULO DE ALMACENAMIENTO (S3 BUCKETS)
# ============================================
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment

  tags = var.tags
}

# ============================================
# 4. MÓDULO DE COMPUTO (ALB, ECS FARGATE, AUTO SCALING)
# ============================================
module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  ecs_tasks_min      = var.ecs_tasks_min
  ecs_tasks_max      = var.ecs_tasks_max
  ecs_cpu            = var.ecs_cpu
  ecs_memory         = var.ecs_memory

  tags = var.tags
}

# ============================================
# 5. MÓDULO DE BASES DE DATOS (AURORA, DYNAMODB, REDIS)
# ============================================
module "database" {
  source = "./modules/database"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  isolated_subnet_ids = module.networking.isolated_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  aurora_min_capacity = var.aurora_min_capacity
  aurora_max_capacity = var.aurora_max_capacity
  redis_node_type     = var.redis_node_type
  redis_num_nodes     = var.redis_num_nodes

  tags = var.tags
}

# ============================================
# 6. MÓDULO DE API (API GATEWAY, LAMBDA)
# ============================================
module "api" {
  source = "./modules/api"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  alb_dns_name         = module.compute.alb_dns_name
  cognito_user_pool_id = module.security.cognito_user_pool_id
  dynamodb_tables      = module.database.dynamodb_tables
  redis_endpoint       = module.database.redis_cluster_endpoint

  tags = var.tags
}

# ============================================
# 7. MÓDULO DE OBSERVABILIDAD (CLOUDWATCH, X-RAY, SNS, GRAFANA)
# ============================================
module "observability" {
  source = "./modules/observability"

  project_name     = var.project_name
  environment      = var.environment
  alb_arn          = module.compute.alb_arn
  ecs_cluster_name = module.compute.ecs_cluster_name
  aurora_arn       = module.database.aurora_cluster_arn

  tags = var.tags
}

# ============================================
# 8. MÓDULO DE CI/CD (ECR, GITHUB ACTIONS ROLE)
# ============================================
module "ci_cd" {
  source = "./modules/ci-cd"

  project_name = var.project_name
  environment  = var.environment

  tags = var.tags
}