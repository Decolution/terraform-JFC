# ============================================
# DATABASE MODULE - AURORA, DYNAMODB, REDIS
# ============================================

# ============================================
# 1. SECURITY GROUPS
# ============================================

# Security Group para Aurora
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-sg"
  description = "Security group for Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-sg"
  })
}

# Security Group para Redis
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-sg"
  })
}

# Security Group para ECS (referencia)
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-db-sg"
  description = "Security group for ECS to access databases"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-db-sg"
  })
}

# ============================================
# 2. AURORA POSTGRESQL SERVERLESS V2
# ============================================

# Subnet Group para Aurora
resource "aws_db_subnet_group" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-subnet-group"
  description = "Subnet group for Aurora"
  subnet_ids  = var.isolated_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-subnet-group"
  })
}

# Parameter Group para Aurora PostgreSQL
resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-params"
  family      = "aurora-postgresql15"
  description = "Parameter group for Aurora PostgreSQL"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-params"
  })
}

# Cluster de Aurora Serverless v2
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.project_name}-${var.environment}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "15.3"
  engine_mode        = "provisioned"

  database_name               = "ecommerce"
  master_username             = "dbadmin"
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  storage_encrypted            = true
  backup_retention_period      = 35
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_min_capacity
    max_capacity = var.aurora_max_capacity
  }

  deletion_protection = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-cluster"
  })
}

# Instancia Writer (Primary)
resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier         = "${var.project_name}-${var.environment}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  promotion_tier = 0

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-writer"
    Role = "writer"
  })
}

# Instancia Reader 1 (Replica)
resource "aws_rds_cluster_instance" "aurora_reader_1" {
  identifier         = "${var.project_name}-${var.environment}-aurora-reader-1"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  promotion_tier = 1

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-reader-1"
    Role = "reader"
  })
}

# Instancia Reader 2 (Replica)
resource "aws_rds_cluster_instance" "aurora_reader_2" {
  identifier         = "${var.project_name}-${var.environment}-aurora-reader-2"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  promotion_tier = 2

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-reader-2"
    Role = "reader"
  })
}

# ============================================
# 3. DYNAMODB TABLES
# ============================================

# Tabla de Productos
resource "aws_dynamodb_table" "products" {
  name         = "${var.project_name}-${var.environment}-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  global_secondary_index {
    name            = "CategoryIndex"
    hash_key        = "category"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, {
    Name  = "${var.project_name}-${var.environment}-products"
    Table = "products"
  })
}

# Tabla de Carritos
resource "aws_dynamodb_table" "carts" {
  name         = "${var.project_name}-${var.environment}-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, {
    Name  = "${var.project_name}-${var.environment}-carts"
    Table = "carts"
  })
}

# Tabla de Sesiones
resource "aws_dynamodb_table" "sessions" {
  name         = "${var.project_name}-${var.environment}-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "session_id"

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, {
    Name  = "${var.project_name}-${var.environment}-sessions"
    Table = "sessions"
  })
}

# Tabla de Inventario (Cache)
resource "aws_dynamodb_table" "inventory_cache" {
  name         = "${var.project_name}-${var.environment}-inventory-cache"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sku"

  attribute {
    name = "sku"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, {
    Name  = "${var.project_name}-${var.environment}-inventory-cache"
    Table = "inventory_cache"
  })
}

# ============================================
# 4. ELASTICACHE REDIS
# ============================================

# Subnet Group para Redis
resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-subnet-group"
  description = "Subnet group for ElastiCache Redis"
  subnet_ids  = var.isolated_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-subnet-group"
  })
}

# Parameter Group para Redis
resource "aws_elasticache_parameter_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-params"
  family      = "redis7"
  description = "Parameter group for ElastiCache Redis"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-params"
  })
}

# Cluster de Redis (Multi-AZ)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.project_name}-${var.environment}-redis"
  description          = "Redis cluster for e-commerce"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = var.redis_node_type
  num_cache_clusters   = var.redis_num_nodes
  port                 = 6379

  automatic_failover_enabled = true
  multi_az_enabled           = var.redis_num_nodes > 1

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  parameter_group_name = aws_elasticache_parameter_group.redis.name

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit = 7
  snapshot_window          = "05:00-06:00"
  maintenance_window       = "sun:06:00-sun:07:00"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-cluster"
  })
}

# ============================================
# 5. RDS PROXY (Opcional - mejora pooling de conexiones)
# ============================================

resource "aws_db_proxy" "aurora" {
  name                   = "${var.project_name}-${var.environment}-aurora-proxy"
  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_subnet_ids         = var.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.aurora.id]

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.aurora_credentials.arn
    iam_auth    = "DISABLED"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-proxy"
  })
}

# IAM Role para RDS Proxy
resource "aws_iam_role" "rds_proxy" {
  name = "${var.project_name}-${var.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_proxy" {
  role       = aws_iam_role.rds_proxy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSDataFullAccess"
}

# ============================================
# 6. SECRETS MANAGER (Credenciales Aurora)
# ============================================

# Secret para credenciales de Aurora (sin rotación automática)
resource "aws_secretsmanager_secret" "aurora_credentials" {
  name = "${var.project_name}-${var.environment}-aurora-credentials"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-aurora-credentials"
  })
}

# Versión del secreto
resource "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id
  secret_string = jsonencode({
    username = aws_rds_cluster.aurora.master_username
    password = aws_rds_cluster.aurora.master_password
    host     = aws_rds_cluster.aurora.endpoint
    port     = 5432
    dbname   = "ecommerce"
  })
}