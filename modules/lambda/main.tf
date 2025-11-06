resource "aws_lambda_function" "main" {
  filename         = var.source_code_path
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = filebase64sha256(var.source_code_path)

  # Timeout and Memory
  timeout     = var.timeout
  memory_size = var.memory_size

  # VPC Configuration (opcional)
  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  # Environment Variables
  dynamic "environment" {
    for_each = length(var.environment_vars) > 0 ? [1] : []
    content {
      variables = var.environment_vars
    }
  }

  # Dead Letter Queue
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Tracing (X-Ray)
  tracing_config {
    mode = var.tracing_mode
  }

  # Reserved Concurrent Executions
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Ephemeral Storage
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  # Layers
  layers = var.layers

  # Architecture
  architectures = [var.architecture]

  # Logging
  logging_config {
    log_format = var.log_format
    log_group  = var.log_group_name != null ? var.log_group_name : "/aws/lambda/${var.function_name}"
  }

  tags = merge(
    {
      Name        = var.function_name
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = var.log_group_name != null ? var.log_group_name : "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.function_name}-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Lambda Alias (opcional)
resource "aws_lambda_alias" "main" {
  count = var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = "Alias for ${var.function_name}"
  function_name    = aws_lambda_function.main.function_name
  function_version = var.alias_function_version

  dynamic "routing_config" {
    for_each = var.alias_routing_additional_version_weights != null ? [1] : []
    content {
      additional_version_weights = var.alias_routing_additional_version_weights
    }
  }
}

# Lambda Permission (para outros serviços invocarem)
resource "aws_lambda_permission" "allow_services" {
  count = length(var.allowed_triggers)

  statement_id  = "AllowExecutionFrom${var.allowed_triggers[count.index].service_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "${var.allowed_triggers[count.index].service_name}.amazonaws.com"
  source_arn    = var.allowed_triggers[count.index].source_arn
}

# Event Source Mapping (para DynamoDB Streams, Kinesis, SQS, etc)
resource "aws_lambda_event_source_mapping" "main" {
  count = length(var.event_source_mappings)

  event_source_arn  = var.event_source_mappings[count.index].event_source_arn
  function_name     = aws_lambda_function.main.arn
  starting_position = lookup(var.event_source_mappings[count.index], "starting_position", null)
  batch_size        = lookup(var.event_source_mappings[count.index], "batch_size", 10)
  enabled           = lookup(var.event_source_mappings[count.index], "enabled", true)

  dynamic "filter_criteria" {
    for_each = lookup(var.event_source_mappings[count.index], "filter_criteria", null) != null ? [1] : []
    content {
      filter {
        pattern = var.event_source_mappings[count.index].filter_criteria
      }
    }
  }
}

# Lambda Function URL (opcional)
resource "aws_lambda_function_url" "main" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [1] : []
    content {
      allow_credentials = lookup(var.function_url_cors, "allow_credentials", false)
      allow_origins     = lookup(var.function_url_cors, "allow_origins", ["*"])
      allow_methods     = lookup(var.function_url_cors, "allow_methods", ["*"])
      allow_headers     = lookup(var.function_url_cors, "allow_headers", [])
      expose_headers    = lookup(var.function_url_cors, "expose_headers", [])
      max_age           = lookup(var.function_url_cors, "max_age", 0)
    }
  }
}

# CloudWatch Alarms (opcional)
resource "aws_cloudwatch_metric_alarm" "errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.error_alarm_threshold
  alarm_description   = "Alarme quando há erros na função Lambda"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = {
    Name        = "${var.function_name}-error-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "throttles" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.function_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.throttle_alarm_threshold
  alarm_description   = "Alarme quando há throttling na função Lambda"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = {
    Name        = "${var.function_name}-throttle-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}
