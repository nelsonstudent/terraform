output "function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.main.arn
}

output "invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = aws_lambda_function.main
}  
