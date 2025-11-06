variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN da IAM role para Lambda"
  type        = string
}

variable "handler" {
  description = "Handler da função Lambda (ex: index.handler)"
  type        = string
}

variable "runtime" {
  description = "Runtime da função (ex: python3.11, nodejs20.x)"
  type        = string
}

variable "source_code_path" {
  description = "Caminho para o arquivo zip com o código"
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

# Configuration
variable "timeout" {
  description = "Timeout da função em segundos (1-900)"
  type        = number
  default     = 30

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Memória alocada em MB (128-10240)"
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "ephemeral_storage_size" {
  description = "Tamanho do storage efêmero em MB (512-10240)"
  type        = number
  default     = 512

  validation {
    condition     = var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    error_message = "Ephemeral storage must be between 512 and 10240 MB."
  }
}

variable "architecture" {
  description = "Arquitetura da função (x86_64 ou arm64)"
  type        = string
  default     = "x86_64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "Architecture must be x86_64 or arm64."
  }
}

# VPC Configuration
variable "subnet_ids" {
  description = "IDs das subnets para a função Lambda (VPC)"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "IDs dos security groups"
  type        = list(string)
  default     = []
}

# Environment Variables
variable "environment_vars" {
  description = "Variáveis de ambiente para a função"
  type        = map(string)
  default     = {}
}

# Logging
variable "log_group_name" {
  description = "Nome do CloudWatch Log Group (null = usar padrão)"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 7
}

variable "log_format" {
  description = "Formato dos logs (Text ou JSON)"
  type        = string
  default     = "Text"

  validation {
    condition     = contains(["Text", "JSON"], var.log_format)
    error_message = "Log format must be Text or JSON."
  }
}

# Tracing
variable "tracing_mode" {
  description = "Modo de tracing X-Ray (PassThrough ou Active)"
  type        = string
  default     = "PassThrough"

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_mode)
    error_message = "Tracing mode must be PassThrough or Active."
  }
}

# Dead Letter Queue
variable "dead_letter_target_arn" {
  description = "ARN do SNS ou SQS para dead letter queue"
  type        = string
  default     = null
}

# Concurrency
variable "reserved_concurrent_executions" {
  description = "Número de execuções concorrentes reservadas (-1 = sem limite)"
  type        = number
  default     = -1
}

# Layers
variable "layers" {
  description = "Lista de ARNs de Lambda layers"
  type        = list(string)
  default     = []
}

# Alias
variable "create_alias" {
  description = "Criar alias para a função"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Nome do alias"
  type        = string
  default     = "live"
}

variable "alias_function_version" {
  description = "Versão da função para o alias ($LATEST ou número)"
  type        = string
  default     = "$LATEST"
}

variable "alias_routing_additional_version_weights" {
  description = "Map de versões adicionais e pesos para routing"
  type        = map(number)
  default     = null
}

# Triggers
variable "allowed_triggers" {
  description = "Lista de serviços autorizados a invocar a função"
  type = list(object({
    service_name = string
    source_arn   = string
  }))
  default = []
}

# Event Source Mapping
variable "event_source_mappings" {
  description = "Lista de event source mappings"
  type = list(object({
    event_source_arn  = string
    starting_position = optional(string)
    batch_size        = optional(number)
    enabled           = optional(bool)
    filter_criteria   = optional(string)
  }))
  default = []
}

# Function URL
variable "create_function_url" {
  description = "Criar Lambda Function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Tipo de autenticação para Function URL (NONE ou AWS_IAM)"
  type        = string
  default     = "AWS_IAM"

  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_auth_type)
    error_message = "Function URL auth type must be NONE or AWS_IAM."
  }
}

variable "function_url_cors" {
  description = "Configuração de CORS para Function URL"
  type = object({
    allow_credentials = optional(bool)
    allow_origins     = optional(list(string))
    allow_methods     = optional(list(string))
    allow_headers     = optional(list(string))
    expose_headers    = optional(list(string))
    max_age           = optional(number)
  })
  default = null
}

# CloudWatch Alarms
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes do CloudWatch"
  type        = bool
  default     = false
}

variable "error_alarm_threshold" {
  description = "Threshold para alarme de erros"
  type        = number
  default     = 5
}

variable "throttle_alarm_threshold" {
  description = "Threshold para alarme de throttling"
  type        = number
  default     = 3
}

# Tags
variable "additional_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
