# ============================================
# OUTPUTS - API MODULE
# ============================================

output "api_gateway_id" {
  description = "ID del API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_url" {
  description = "URL del API Gateway"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/api"
}

output "lambda_function_names" {
  description = "Nombres de las funciones Lambda"
  value = {
    get_products        = aws_lambda_function.get_products.function_name
    get_product_details = aws_lambda_function.get_product_details.function_name
    add_to_cart         = aws_lambda_function.add_to_cart.function_name
    get_cart            = aws_lambda_function.get_cart.function_name
    search_products     = aws_lambda_function.search_products.function_name
  }
}

output "lambda_role_arn" {
  description = "ARN del rol IAM de Lambda"
  value       = aws_iam_role.lambda.arn
}