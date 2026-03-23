# ============================================
# OUTPUTS - NETWORKING MODULE
# ============================================

output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "IDs de las subnets aisladas"
  value       = aws_subnet.isolated[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks de las subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks de las subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "isolated_subnet_cidrs" {
  description = "CIDR blocks de las subnets aisladas"
  value       = aws_subnet.isolated[*].cidr_block
}

output "nat_gateway_ids" {
  description = "IDs de los NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}