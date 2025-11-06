# ==========================================
# Required Variables
# ==========================================
variable "table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Chave hash (partition key) da tabela"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

# ==========================================
# Optional Variables - Basic Configuration
# ==========================================
variable "range_key" {
  description = "Chave range (sort key) da tabela"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Modo de billing: PROVISIONED ou PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "Read capacity units (usado apenas se billing_mode = PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (usado apenas se billing_mode = PROVISIONED)"
  type        = number
  default     = 5
}

variable "table_class" {
  description = "Classe da tabela: STANDARD ou STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

# ==========================================
# Attributes Configuration
# ==========================================
variable "attributes" {
  description = "Lista de atributos da tabela (name e type)"
  type = list(object({
    name = string
    type = string # S (string), N (number), B (binary)
  }))
  default = [
    {
      name = "id"
      type = "S"
    }
  ]

  validation {
    condition = alltrue([
      for attr in var.attributes : contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute type must be S (string), N (number), or B (binary)."
  }
}

# ==========================================
# TTL Configuration
# ==========================================
variable "ttl_enabled" {
  description = "Habilitar Time To Live (TTL)"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Nome do atributo usado para TTL"
  type        = string
  default     = "ttl"
}

# ==========================================
# Encryption Configuration
# ==========================================
variable "encryption_enabled" {
  description = "Habilitar criptografia server-side"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN da chave KMS para criptografia (null = usar chave padrão da AWS)"
  type        = string
  default     = null
}

# ==========================================
# Backup Configuration
# ==========================================
variable "point_in_time_recovery_enabled" {
  description = "Habilitar Point-in-Time Recovery (PITR)"
  type        = bool
  default     = true
}

# ==========================================
# Stream Configuration
# ==========================================
variable "stream_enabled" {
  description = "Habilitar DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Tipo de view do stream: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

# ==========================================
# Global Secondary Indexes (GSI)
# ==========================================
variable "global_secondary_indexes" {
  description = "Lista de Global Secondary Indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

# ==========================================
# Local Secondary Indexes (LSI)
# ==========================================
variable "local_secondary_indexes" {
  description = "Lista de Local Secondary Indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string))
  }))
  default = []
}

# ==========================================
# Global Tables (Replication)
# ==========================================
variable "replica_regions" {
  description = "Lista de regiões para replicação (Global Tables)"
  type        = list(string)
  default     = []
}

variable "replica_kms_key_arns" {
  description = "Map de ARNs de chaves KMS por região para réplicas"
  type        = map(string)
  default     = {}
}

# ==========================================
# Auto Scaling Configuration
# ==========================================
variable "autoscaling_enabled" {
  description = "Habilitar auto scaling (usado apenas com PROVISIONED)"
  type        = bool
  default     = false
}

variable "autoscaling_read_max_capacity" {
  description = "Capacidade máxima de leitura para auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_max_capacity" {
  description = "Capacidade máxima de escrita para auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_read_target_value" {
  description = "Utilização alvo para auto scaling de leitura (0-100%)"
  type        = number
  default     = 70
}

variable "autoscaling_write_target_value" {
  description = "Utilização alvo para auto scaling de escrita (0-100%)"
  type        = number
  default     = 70
}

# ==========================================
# CloudWatch Alarms
# ==========================================
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes do CloudWatch"
  type        = bool
  default     = false
}

variable "read_throttle_alarm_threshold" {
  description = "Threshold para alarme de throttle de leitura"
  type        = number
  default     = 10
}

variable "write_throttle_alarm_threshold" {
  description = "Threshold para alarme de throttle de escrita"
  type        = number
  default     = 10
}

# ==========================================
# Tags
# ==========================================
variable "additional_tags" {
  description = "Tags adicionais para aplicar aos recursos"
  type        = map(string)
  default     = {}
}
