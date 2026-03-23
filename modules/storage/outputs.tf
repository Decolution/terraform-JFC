# ============================================
# OUTPUTS - STORAGE MODULE
# ============================================

output "frontend_bucket_id" {
  description = "ID del bucket S3 para frontend"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_arn" {
  description = "ARN del bucket S3 para frontend"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_domain" {
  description = "Dominio del bucket S3 para frontend"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "frontend_website_endpoint" {
  description = "Endpoint del sitio web estático"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

# AGREGAR ESTOS OUTPUTS:
output "frontend_bucket_name" {
  description = "Nombre del bucket S3 para frontend"
  value       = aws_s3_bucket.frontend.id
}

output "media_bucket_name" {
  description = "Nombre del bucket S3 para media"
  value       = aws_s3_bucket.media.id
}

output "media_bucket_id" {
  description = "ID del bucket S3 para media"
  value       = aws_s3_bucket.media.id
}

output "media_bucket_arn" {
  description = "ARN del bucket S3 para media"
  value       = aws_s3_bucket.media.arn
}

output "logs_bucket_id" {
  description = "ID del bucket S3 para logs"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "ARN del bucket S3 para logs"
  value       = aws_s3_bucket.logs.arn
}

output "cloudfront_oai_id" {
  description = "ID del Origin Access Identity para CloudFront"
  value       = aws_cloudfront_origin_access_identity.media.id
}

output "cloudfront_oai_arn" {
  description = "ARN del Origin Access Identity para CloudFront"
  value       = aws_cloudfront_origin_access_identity.media.iam_arn
}