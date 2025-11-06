# Volume Information
output "volume_id" {
  description = "ID do volume EBS"
  value       = aws_ebs_volume.main.id
}

output "volume_arn" {
  description = "ARN do volume EBS"
  value       = aws_ebs_volume.main.arn
}

output "volume_size" {
  description = "Tamanho do volume em GB"
  value       = aws_ebs_volume.main.size
}

output "volume_type" {
  description = "Tipo do volume EBS"
  value       = aws_ebs_volume.main.type
}

output "iops" {
  description = "IOPS provisionados do volume"
  value       = aws_ebs_volume.main.iops
}

output "throughput" {
  description = "Throughput do volume em MB/s"
  value       = aws_ebs_volume.main.throughput
}

output "encrypted" {
  description = "Se o volume está criptografado"
  value       = aws_ebs_volume.main.encrypted
}

output "kms_key_id" {
  description = "ARN da chave KMS usada para criptografia"
  value       = aws_ebs_volume.main.kms_key_id
}

output "availability_zone" {
  description = "Availability zone onde o volume está localizado"
  value       = aws_ebs_volume.main.availability_zone
}

output "snapshot_id" {
  description = "ID do snapshot usado para criar o volume"
  value       = aws_ebs_volume.main.snapshot_id
}

output "multi_attach_enabled" {
  description = "Se multi-attach está habilitado"
  value       = aws_ebs_volume.main.multi_attach_enabled
}

# Attachment Information
output "attachment_id" {
  description = "ID do volume attachment"
  value       = var.instance_id != null ? aws_volume_attachment.main[0].id : null
}

output "attachment_device_name" {
  description = "Nome do device do attachment"
  value       = var.instance_id != null ? aws_volume_attachment.main[0].device_name : null
}

output "attachment_instance_id" {
  description = "ID da instância EC2 onde o volume está anexado"
  value       = var.instance_id != null ? aws_volume_attachment.main[0].instance_id : null
}

output "is_attached" {
  description = "Se o volume está anexado a uma instância"
  value       = var.instance_id != null
}

# Snapshot Lifecycle Information
output "snapshot_policy_id" {
  description = "ID da política de snapshot lifecycle (DLM)"
  value       = var.enable_snapshot_lifecycle ? aws_dlm_lifecycle_policy.ebs_snapshot[0].id : null
}

output "snapshot_policy_arn" {
  description = "ARN da política de snapshot lifecycle (DLM)"
  value       = var.enable_snapshot_lifecycle ? aws_dlm_lifecycle_policy.ebs_snapshot[0].arn : null
}

output "dlm_role_arn" {
  description = "ARN da IAM role usada pelo DLM"
  value       = local.dlm_role_arn
}

# CloudWatch Alarms
output "idle_alarm_arn" {
  description = "ARN do alarme de idle time"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.volume_idle[0].arn : null
}

output "burst_balance_alarm_arn" {
  description = "ARN do alarme de burst balance"
  value       = var.enable_cloudwatch_alarms && contains(["gp2", "st1", "sc1"], var.volume_type) ? aws_cloudwatch_metric_alarm.burst_balance_low[0].arn : null
}

output "read_ops_alarm_arn" {
  description = "ARN do alarme de operações de leitura"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.volume_read_ops_high[0].arn : null
}

output "write_ops_alarm_arn" {
  description = "ARN do alarme de operações de escrita"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.volume_write_ops_high[0].arn : null
}

# Tags
output "tags" {
  description = "Tags aplicadas ao volume"
  value       = aws_ebs_volume.main.tags
}

# Status Information
output "state" {
  description = "Estado atual do volume (available, in-use, creating, deleting)"
  value       = aws_ebs_volume.main.state
}

# Useful Information
output "volume_info" {
  description = "Informações consolidadas do volume para referência rápida"
  value = {
    id                = aws_ebs_volume.main.id
    arn               = aws_ebs_volume.main.arn
    size              = aws_ebs_volume.main.size
    type              = aws_ebs_volume.main.type
    availability_zone = aws_ebs_volume.main.availability_zone
    encrypted         = aws_ebs_volume.main.encrypted
    state             = aws_ebs_volume.main.state
    attached_to       = var.instance_id
  }
}
