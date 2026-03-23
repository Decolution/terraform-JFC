# ============================================
# API MODULE - API GATEWAY, LAMBDA, DAX
# ============================================

# ============================================
# 1. API GATEWAY
# ============================================

# API REST
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API Gateway for JFC e-commerce"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-api"
  })
}

# Recurso raíz
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "api"
}

# ============================================
# 2. LAMBDA FUNCTIONS (Operaciones Simples)
# ============================================

# IAM Role para Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Política para Lambda (CloudWatch logs)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para Lambda (acceso a DynamoDB)
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-${var.environment}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          for table in values(var.dynamodb_tables) : "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${table}"
        ]
      }
    ]
  })
}

# Política para Lambda (acceso a Redis via VPC)
resource "aws_iam_role_policy" "lambda_vpc" {
  name = "${var.project_name}-${var.environment}-lambda-vpc-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Función Lambda: Get Products
resource "aws_lambda_function" "get_products" {
  filename      = data.archive_file.empty.output_path
  function_name = "${var.project_name}-${var.environment}-get-products"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  memory_size   = 512
  timeout       = 10

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_tables["products"]
      REDIS_ENDPOINT = var.redis_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-get-products"
    Function = "get_products"
  })
}

# Función Lambda: Get Product Details
resource "aws_lambda_function" "get_product_details" {
  filename      = data.archive_file.empty.output_path
  function_name = "${var.project_name}-${var.environment}-get-product-details"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  memory_size   = 512
  timeout       = 10

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_tables["products"]
      REDIS_ENDPOINT = var.redis_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-get-product-details"
    Function = "get_product_details"
  })
}

# Función Lambda: Add to Cart
resource "aws_lambda_function" "add_to_cart" {
  filename      = data.archive_file.empty.output_path
  function_name = "${var.project_name}-${var.environment}-add-to-cart"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  memory_size   = 256
  timeout       = 5

  environment {
    variables = {
      DYNAMODB_CART_TABLE = var.dynamodb_tables["carts"]
      REDIS_ENDPOINT      = var.redis_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-add-to-cart"
    Function = "add_to_cart"
  })
}

# Función Lambda: Get Cart
resource "aws_lambda_function" "get_cart" {
  filename      = data.archive_file.empty.output_path
  function_name = "${var.project_name}-${var.environment}-get-cart"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  memory_size   = 256
  timeout       = 5

  environment {
    variables = {
      DYNAMODB_CART_TABLE = var.dynamodb_tables["carts"]
      REDIS_ENDPOINT      = var.redis_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-get-cart"
    Function = "get_cart"
  })
}

# Función Lambda: Search Products
resource "aws_lambda_function" "search_products" {
  filename      = data.archive_file.empty.output_path
  function_name = "${var.project_name}-${var.environment}-search-products"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  memory_size   = 1024
  timeout       = 15

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_tables["products"]
      REDIS_ENDPOINT = var.redis_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-search-products"
    Function = "search_products"
  })
}

# ============================================
# 3. API GATEWAY INTEGRATIONS
# ============================================

# Método GET /api/products
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.root.id
  path_part   = "products"
}

resource "aws_api_gateway_method" "get_products" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_products" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.products.id
  http_method = aws_api_gateway_method.get_products.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_products.invoke_arn
}

# Método GET /api/products/{id}
resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.products.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_product" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "get_product" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.product.id
  http_method = aws_api_gateway_method.get_product.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_product_details.invoke_arn
}

# Método POST /api/cart
resource "aws_api_gateway_resource" "cart" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.root.id
  path_part   = "cart"
}

resource "aws_api_gateway_method" "post_cart" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.cart.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "post_cart" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.cart.id
  http_method = aws_api_gateway_method.post_cart.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_to_cart.invoke_arn
}

# Método GET /api/cart
resource "aws_api_gateway_method" "get_cart" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.cart.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_cart" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.cart.id
  http_method = aws_api_gateway_method.get_cart.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_cart.invoke_arn
}

# Método GET /api/search
resource "aws_api_gateway_resource" "search" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.root.id
  path_part   = "search"
}

resource "aws_api_gateway_method" "search" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.search.id
  http_method   = "GET"
  authorization = "NONE" # Búsqueda pública
}

resource "aws_api_gateway_integration" "search" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.search.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.search_products.invoke_arn
}

# Método POST /api/orders (redirige a ALB)
resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.root.id
  path_part   = "orders"
}

resource "aws_api_gateway_method" "post_orders" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "post_orders" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = aws_api_gateway_method.post_orders.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${var.alb_dns_name}/orders"
}

# ============================================
# 4. COGNITO AUTHORIZER
# ============================================

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.project_name}-${var.environment}-cognito-authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  provider_arns = [var.cognito_user_pool_id]
}

# ============================================
# 5. LAMBDA PERMISSIONS
# ============================================

resource "aws_lambda_permission" "get_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_product_details" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product_details.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "add_to_cart" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_to_cart.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_cart" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_cart.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "search_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.search_products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ============================================
# 6. DEPLOYMENT
# ============================================

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.root.id,
      aws_api_gateway_resource.products.id,
      aws_api_gateway_resource.cart.id,
      aws_api_gateway_resource.search.id,
      aws_api_gateway_resource.orders.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  tags = var.tags
}

# ============================================
# 7. SECURITY GROUP FOR LAMBDA
# ============================================

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-lambda-sg"
  })
}

# ============================================
# 8. DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "empty" {
  type        = "zip"
  output_path = "${path.module}/empty.zip"

  source {
    content  = "exports.handler = async () => ({ statusCode: 200, body: 'OK' });"
    filename = "index.js"
  }
}