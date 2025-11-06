# ==========================================
# EC2 Outputs
# ==========================================
output "ec2_iam_role_name" {
  description = "Nome da IAM Role criada para EC2"
  value       = aws_iam_role.ec2.name
}

output "ec2_iam_role_arn" {
  description = "ARN da IAM Role criada para EC2"
  value       = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "Nome do IAM Instance Profile para EC2"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "ARN do IAM Instance Profile para EC2"
  value       = aws_iam_instance_profile.ec2.arn
}

# ==========================================
# Lambda Outputs
# ==========================================
output "lambda_iam_role_name" {
  description = "Nome da IAM Role criada para Lambda"
  value       = aws_iam_role.lambda.name
}

output "lambda_iam_role_arn" {
  description = "ARN da IAM Role criada para Lambda"
  value       = aws_iam_role.lambda.arn
}

# ==========================================
# RDS Outputs
# ==========================================
output "rds_monitoring_iam_role_name" {
  description = "Nome da IAM Role para RDS Enhanced Monitoring"
  value       = var.enable_rds_monitoring_role ? aws_iam_role.rds_monitoring[0].name : null
}

output "rds_monitoring_iam_role_arn" {
  description = "ARN da IAM Role para RDS Enhanced Monitoring"
  value       = var.enable_rds_monitoring_role ? aws_iam_role.rds_monitoring[0].arn : null
}

# ==========================================
# Auto Scaling Outputs
# ==========================================
output "autoscaling_role_name" {
  description = "Nome da IAM Role para Application Auto Scaling"
  value       = var.enable_autoscaling_role ? aws_iam_role.autoscaling[0].name : null
}

output "autoscaling_role_arn" {
  description = "ARN da IAM Role para Application Auto Scaling"
  value       = var.enable_autoscaling_role ? aws_iam_role.autoscaling[0].arn : null
}

# ==========================================
# MFA/Admin Group Outputs
# ==========================================
output "admin_group_name" {
  description = "Nome do grupo de administradores IAM"
  value       = aws_iam_group.admins.name
}

output "mfa_policy_arn" {
  description = "ARN da política que exige MFA"
  value       = aws_iam_policy.force_mfa.arn
}
