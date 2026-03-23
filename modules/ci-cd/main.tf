# ============================================
# CI/CD MODULE - ECR REPOSITORIES
# ============================================

# ============================================
# 1. ECR REPOSITORIES (Imágenes Docker)
# ============================================

# Repositorio para Orders Service
resource "aws_ecr_repository" "orders" {
  name = "${var.project_name}-${var.environment}-orders"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-orders"
    Service  = "orders"
    RepoType = "ecr"
  })
}

# Repositorio para Payments Service
resource "aws_ecr_repository" "payments" {
  name = "${var.project_name}-${var.environment}-payments"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-payments"
    Service  = "payments"
    RepoType = "ecr"
  })
}

# Repositorio para Inventory Service
resource "aws_ecr_repository" "inventory" {
  name = "${var.project_name}-${var.environment}-inventory"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-inventory"
    Service  = "inventory"
    RepoType = "ecr"
  })
}

# Repositorio para Users Service
resource "aws_ecr_repository" "users" {
  name = "${var.project_name}-${var.environment}-users"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-users"
    Service  = "users"
    RepoType = "ecr"
  })
}

# ============================================
# 2. ECR LIFECYCLE POLICY (Mantener solo últimas imágenes)
# ============================================

resource "aws_ecr_lifecycle_policy" "orders" {
  repository = aws_ecr_repository.orders.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "payments" {
  repository = aws_ecr_repository.payments.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "inventory" {
  repository = aws_ecr_repository.inventory.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "users" {
  repository = aws_ecr_repository.users.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================
# 3. IAM ROLE PARA GITHUB ACTIONS (CI/CD)
# ============================================

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.project_name}/*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Política para GitHub Actions (ECR)
resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "${var.project_name}-${var.environment}-github-actions-ecr-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetLifecyclePolicy",
          "ecr:PutLifecyclePolicy"
        ]
        Resource = [
          aws_ecr_repository.orders.arn,
          aws_ecr_repository.payments.arn,
          aws_ecr_repository.inventory.arn,
          aws_ecr_repository.users.arn
        ]
      }
    ]
  })
}

# Política para GitHub Actions (ECS)
resource "aws_iam_role_policy" "github_actions_ecs" {
  name = "${var.project_name}-${var.environment}-github-actions-ecs-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-ecs-execution-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-ecs-task-role"
        ]
      }
    ]
  })
}

# Política para GitHub Actions (Secrets Manager)
resource "aws_iam_role_policy" "github_actions_secrets" {
  name = "${var.project_name}-${var.environment}-github-actions-secrets-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-${var.environment}-*"
      }
    ]
  })
}

# ============================================
# 4. GITHUB ACTIONS SECRETS (Outputs para usar en workflow)
# ============================================

# Estos outputs se definen en outputs.tf
# Los secretos deben configurarse manualmente en GitHub:
# - AWS_ROLE_ARN = aws_iam_role.github_actions.arn
# - AWS_REGION = us-east-1
# - ECR_REPOSITORY_ORDERS = aws_ecr_repository.orders.repository_url
# - ECR_REPOSITORY_PAYMENTS = aws_ecr_repository.payments.repository_url
# - ECR_REPOSITORY_INVENTORY = aws_ecr_repository.inventory.repository_url
# - ECR_REPOSITORY_USERS = aws_ecr_repository.users.repository_url

# ============================================
# 5. DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}