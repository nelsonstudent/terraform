output "bucket_id" {
  description = "ID do bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_name" {
  description = "Nome do bucket"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "ARN do bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Domain name do bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name do bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_region" {
  description = "Região do bucket"
  value       = aws_s3_bucket.main.region
}

output "bucket_hosted_zone_id" {
  description = "Hosted zone ID do bucket (Route 53)"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "versioning_enabled" {
  description = "Se versionamento está habilitado"
  value       = var.enable_versioning
}

output "encryption_algorithm" {
  description = "Algoritmo de criptografia usado"
  value       = var.encryption_algorithm
}

output "website_endpoint" {
  description = "Endpoint do website (se habilitado)"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.main[0].website_endpoint : null
}

output "website_domain" {
  description = "Domain do website (se habilitado)"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.main[0].website_domain : null
}

output "replication_configuration_id" {
  description = "ID da configuração de replicação"
  value       = var.enable_replication ? aws_s3_bucket_replication_configuration.main[0].id : null
}

output "object_lock_enabled" {
  description = "Se Object Lock está habilitado"
  value       = var.enable_object_lock
}

output "tags" {
  description = "Tags aplicadas ao bucket"
  value       = aws_s3_bucket.main.tags
}

# URLs úteis
output "bucket_url" {
  description = "URL do bucket"
  value       = "s3://${aws_s3_bucket.main.bucket}"
}

output "bucket_https_url" {
  description = "URL HTTPS do bucket"
  value       = "https://${aws_s3_bucket.main.bucket_regional_domain_name}"
}
