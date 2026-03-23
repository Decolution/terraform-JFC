# ============================================
# OUTPUTS - CI/CD MODULE
# ============================================

output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR"
  value = {
    orders    = aws_ecr_repository.orders.repository_url
    payments  = aws_ecr_repository.payments.repository_url
    inventory = aws_ecr_repository.inventory.repository_url
    users     = aws_ecr_repository.users.repository_url
  }
}

output "ecr_repository_arns" {
  description = "ARNs de los repositorios ECR"
  value = {
    orders    = aws_ecr_repository.orders.arn
    payments  = aws_ecr_repository.payments.arn
    inventory = aws_ecr_repository.inventory.arn
    users     = aws_ecr_repository.users.arn
  }
}

output "github_actions_role_arn" {
  description = "ARN del rol IAM para GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Nombre del rol IAM para GitHub Actions"
  value       = aws_iam_role.github_actions.name
}