variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets para o DB subnet group"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "IDs dos security groups"
  type        = list(string)
}

# Engine Configuration
variable "engine" {
  description = "Engine do banco de dados (mysql, postgres, mariadb, oracle-ee, sqlserver-ex)"
  type        = string
}

variable "engine_version" {
  description = "Versão da engine"
  type        = string
}

variable "instance_class" {
  description = "Classe da instância (ex: db.t3.micro, db.r5.large)"
  type        = string
}

# Database Configuration
variable "db_name" {
  description = "Nome do database inicial"
  type        = string
}

variable "username" {
  description = "Username master"
  type        = string
}

variable "password" {
  description = "Password master"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Porta do banco de dados"
  type        = number
  default     = null
}

# Storage Configuration
variable "allocated_storage" {
  description = "Storage inicial em GB"
  type        = number
}

variable "max_allocated_storage" {
  description = "Storage máximo para auto scaling (0 = desabilitado)"
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "Tipo de storage (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "IOPS provisionados (para io1/io2)"
  type        = number
  default     = null
}

variable "storage_encrypted" {
  description = "Habilitar criptografia do storage"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN da chave KMS para criptografia"
  type        = string
  default     = null
}

# Network Configuration
variable "publicly_accessible" {
  description = "Tornar o RDS publicamente acessível"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "AZ específica (apenas para single-AZ)"
  type        = string
  default     = null
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Período de retenção de backup em dias (0-35)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Janela de backup diário (formato: hh24:mi-hh24:mi)"
  type        = string
  default     = "03:00-04:00"
}

variable "copy_tags_to_snapshot" {
  description = "Copiar tags para snapshots"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Pular snapshot final ao deletar"
  type        = bool
  default     = false
}

# Maintenance Configuration
variable "maintenance_window" {
  description = "Janela de manutenção (formato: ddd:hh24:mi-ddd:hh24:mi)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Habilitar upgrade automático de versão minor"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Aplicar mudanças imediatamente"
  type        = bool
  default     = false
}

# High Availability
variable "multi_az" {
  description = "Habilitar Multi-AZ"
  type        = bool
  default     = false
}

# Monitoring
variable "enabled_cloudwatch_logs_exports" {
  description = "Lista de tipos de logs para exportar para CloudWatch"
  type        = list(string)
  default     = []
}

variable "monitoring_interval" {
  description = "Intervalo de enhanced monitoring em segundos (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "ARN da IAM role para enhanced monitoring"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Habilitar Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "ARN da chave KMS para Performance Insights"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Período de retenção do Performance Insights em dias (7 ou 731)"
  type        = number
  default     = 7
}

# Deletion Protection
variable "deletion_protection" {
  description = "Habilitar proteção contra deleção"
  type        = bool
  default     = false
}

# Parameter Group
variable "create_parameter_group" {
  description = "Criar parameter group customizado"
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Nome de parameter group existente"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Family do parameter group (ex: mysql8.0, postgres14)"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "Lista de parâmetros customizados"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Option Group
variable "create_option_group" {
  description = "Criar option group customizado"
  type        = bool
  default     = false
}

variable "option_group_name" {
  description = "Nome de option group existente"
  type        = string
  default     = null
}

variable "major_engine_version" {
  description = "Versão major da engine para option group"
  type        = string
  default     = ""
}

variable "options" {
  description = "Lista de options"
  type = list(object({
    option_name     = string
    option_settings = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default = []
}

# Additional Configuration
variable "character_set_name" {
  description = "Character set para MySQL/MariaDB"
  type        = string
  default     = null
}

variable "timezone" {
  description = "Timezone para SQL Server"
  type        = string
  default     = null
}

variable "replicate_source_db" {
  description = "ARN do RDS para criar read replica"
  type        = string
  default     = null
}

# CloudWatch Alarms
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes do CloudWatch"
  type        = bool
  default     = false
}

variable "cpu_alarm_threshold" {
  description = "Threshold de CPU para alarme (%)"
  type        = number
  default     = 80
}

variable "storage_alarm_threshold" {
  description = "Threshold de storage livre para alarme (bytes)"
  type        = number
  default     = 10737418240 # 10 GB
}

variable "connection_alarm_threshold" {
  description = "Threshold de conexões para alarme"
  type        = number
  default     = 80
}

# Tags
variable "additional_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
