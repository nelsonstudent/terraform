variable "bucket_name" {
  description = "Nome do bucket S3 (deve ser globalmente único)"
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

variable "force_destroy" {
  description = "Permitir deletar bucket mesmo com objetos dentro"
  type        = bool
  default     = false
}

# Versioning
variable "enable_versioning" {
  description = "Habilitar versionamento"
  type        = bools
  default     = true
}

# Encryption
variable "encryption_algorithm" {
  description = "Algoritmo de criptografia (AES256 ou aws:kms)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  description = "ARN da chave KMS (necessário se encryption_algorithm = aws:kms)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Habilitar S3 Bucket Key para reduzir custos KMS"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Habilita ou desabilita a criptografia server-side."
  type        = bool
  default     = true
}

# Public Access
variable "block_public_access" {
  description = "Bloquear todo acesso público"
  type        = bool
  default     = true
}

# Lifecycle Rules
variable "lifecycle_rules" {
  description = "Lista de regras de lifecycle"
  type = list(object({
    id                                   = string
    status                               = string
    prefix                               = optional(string)
    expiration_days                      = optional(number)
    transitions                          = optional(list(object({
      days          = number
      storage_class = string
    })))
    noncurrent_version_expiration_days   = optional(number)
    noncurrent_version_transitions       = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

# Logging
variable "enable_logging" {
  description = "Habilitar logging de acesso"
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Bucket destino para logs"
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefixo para logs"
  type        = string
  default     = "logs/"
}

# CORS
variable "cors_rules" {
  description = "Lista de regras CORS"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

# Website Hosting
variable "enable_website" {
  description = "Habilitar static website hosting"
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "Documento index para website"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Documento de erro para website"
  type        = string
  default     = null
}

variable "website_routing_rules" {
  description = "Regras de routing para website"
  type = list(object({
    condition = object({
      key_prefix_equals               = optional(string)
      http_error_code_returned_equals = optional(string)
    })
    redirect = object({
      host_name               = optional(string)
      http_redirect_code      = optional(string)
      protocol                = optional(string)
      replace_key_prefix_with = optional(string)
      replace_key_with        = optional(string)
    })
  }))
  default = []
}

# Bucket Policy
variable "bucket_policy" {
  description = "JSON policy para o bucket"
  type        = string
  default     = null
}

# Replication
variable "enable_replication" {
  description = "Habilitar replicação cross-region"
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "ARN da IAM role para replicação"
  type        = string
  default     = null
}

variable "replication_rules" {
  description = "Lista de regras de replicação"
  type = list(object({
    id                        = string
    status                    = string
    priority                  = optional(number)
    prefix                    = optional(string)
    destination_bucket        = string
    storage_class             = optional(string)
    replica_kms_key_id        = optional(string)
    sse_kms_encrypted_objects = optional(bool)
  }))
  default = []
}

# Object Lock
variable "enable_object_lock" {
  description = "Habilitar Object Lock (requer versioning)"
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Modo do Object Lock (GOVERNANCE ou COMPLIANCE)"
  type        = string
  default     = "GOVERNANCE"

  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_mode)
    error_message = "Object lock mode must be GOVERNANCE or COMPLIANCE."
  }
}

variable "object_lock_days" {
  description = "Dias de retenção do Object Lock"
  type        = number
  default     = null
}

variable "object_lock_years" {
  description = "Anos de retenção do Object Lock"
  type        = number
  default     = null
}

# Intelligent Tiering
variable "enable_intelligent_tiering" {
  description = "Habilitar Intelligent Tiering"
  type        = bool
  default     = false
}

variable "intelligent_tiering_archive_days" {
  description = "Dias para mover para Archive Access Tier"
  type        = number
  default     = 90
}

variable "intelligent_tiering_deep_archive_days" {
  description = "Dias para mover para Deep Archive Access Tier"
  type        = number
  default     = 180
}

# Notifications
variable "lambda_notifications" {
  description = "Lista de notificações Lambda"
  type = list(object({
    lambda_function_arn = string
    events              = list(string)
    filter_prefix       = optional(string)
    filter_suffix       = optional(string)
  }))
  default = []
}

variable "sns_notifications" {
  description = "Lista de notificações SNS"
  type = list(object({
    topic_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = []
}

variable "sqs_notifications" {
  description = "Lista de notificações SQS"
  type = list(object({
    queue_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = []
}

# Metrics
variable "enable_metrics" {
  description = "Habilitar CloudWatch metrics"
  type        = bool
  default     = false
}

# Tags
variable "additional_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
