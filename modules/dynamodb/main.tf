# ==========================================
# modules/dynamodb/main.tf
# ==========================================

resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  
  # Capacidade provisionada (usado apenas se billing_mode = PROVISIONED)
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Definição dos atributos
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # TTL (Time to Live)
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  # Point-in-time Recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Server-side Encryption
  server_side_encryption {
    enabled     = var.encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  # Stream Settings
  dynamic "stream_specification" {
    for_each = var.stream_enabled ? [1] : []
    content {
      enabled   = true
      view_type = var.stream_view_type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", var.read_capacity) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", var.write_capacity) : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  # Replica configuration for global tables
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name = replica.value
      kms_key_arn = var.replica_kms_key_arns[replica.value]
    }
  }

  # Table Class (STANDARD or STANDARD_INFREQUENT_ACCESS)
  table_class = var.table_class

  tags = merge(
    {
      Name        = var.table_name
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }
}

# Auto Scaling para Read Capacity (opcional)
resource "aws_appautoscaling_target" "read" {
  count = var.billing_mode == "PROVISIONED" && var.autoscaling_enabled ? 1 : 0

  max_capacity       = var.autoscaling_read_max_capacity
  min_capacity       = var.read_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  count = var.billing_mode == "PROVISIONED" && var.autoscaling_enabled ? 1 : 0

  name               = "${var.table_name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_read_target_value
  }
}

# Auto Scaling para Write Capacity (opcional)
resource "aws_appautoscaling_target" "write" {
  count = var.billing_mode == "PROVISIONED" && var.autoscaling_enabled ? 1 : 0

  max_capacity       = var.autoscaling_write_max_capacity
  min_capacity       = var.write_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  count = var.billing_mode == "PROVISIONED" && var.autoscaling_enabled ? 1 : 0

  name               = "${var.table_name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_write_target_value
  }
}

# CloudWatch Alarms (opcional)
resource "aws_cloudwatch_metric_alarm" "read_throttle_events" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.table_name}-read-throttle-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.read_throttle_alarm_threshold
  alarm_description   = "Alarme quando há throttling nas leituras da tabela ${var.table_name}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  tags = {
    Name        = "${var.table_name}-read-throttle-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "write_throttle_events" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.table_name}-write-throttle-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.write_throttle_alarm_threshold
  alarm_description   = "Alarme quando há throttling nas escritas da tabela ${var.table_name}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  tags = {
    Name        = "${var.table_name}-write-throttle-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}
