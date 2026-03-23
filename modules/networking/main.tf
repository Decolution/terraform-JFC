# ============================================
# NETWORKING MODULE - VPC, SUBNETS, IGW, NAT
# ============================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-vpc"
  })
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-igw"
  })
}

# ============================================
# SUBNETS PÚBLICAS (ALB, NAT Gateway)
# ============================================
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-public-subnet-${count.index + 1}"
    Type = "public"
  })
}

# ============================================
# SUBNETS PRIVADAS (ECS Fargate)
# ============================================
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-private-subnet-${count.index + 1}"
    Type = "private"
  })
}

# ============================================
# SUBNETS AISLADAS (Aurora, Redis)
# ============================================
resource "aws_subnet" "isolated" {
  count = length(var.isolated_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-isolated-subnet-${count.index + 1}"
    Type = "isolated"
  })
}

# ============================================
# ROUTE TABLES PÚBLICAS
# ============================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================
# NAT GATEWAYS (uno por AZ)
# ============================================
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_subnet_cidrs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-nat-gw-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# ============================================
# ROUTE TABLES PRIVADAS (con NAT Gateway)
# ============================================
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================
# ROUTE TABLES AISLADAS (sin internet)
# ============================================
resource "aws_route_table" "isolated" {
  count = length(var.isolated_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  # Sin ruta a internet

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Project", "jfc-ecommerce")}-isolated-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "isolated" {
  count = length(var.isolated_subnet_cidrs)

  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated[count.index].id
}