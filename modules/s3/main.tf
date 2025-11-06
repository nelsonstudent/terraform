# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    {
      Name        = var.bucket_name
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

# Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_algorithm
      kms_master_key_id = var.kms_master_key_id
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = lookup(rule.value, "prefix", null) != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration_days", null) != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transitions", [])
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration_days", null) != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }
}

# Logging
resource "aws_s3_bucket_logging" "main" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.main.id

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "main" {
  count = length(var.cors_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", [])
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", [])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3000)
    }
  }
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "main" {
  count = var.enable_website ? 1 : 0

  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = var.website_index_document
  }

  dynamic "error_document" {
    for_each = var.website_error_document != null ? [1] : []
    content {
      key = var.website_error_document
    }
  }

  dynamic "routing_rule" {
    for_each = var.website_routing_rules
    content {
      condition {
        key_prefix_equals = lookup(routing_rule.value.condition, "key_prefix_equals", null)
        http_error_code_returned_equals = lookup(routing_rule.value.condition, "http_error_code_returned_equals", null)
      }
      redirect {
        host_name               = lookup(routing_rule.value.redirect, "host_name", null)
        http_redirect_code      = lookup(routing_rule.value.redirect, "http_redirect_code", null)
        protocol                = lookup(routing_rule.value.redirect, "protocol", null)
        replace_key_prefix_with = lookup(routing_rule.value.redirect, "replace_key_prefix_with", null)
        replace_key_with        = lookup(routing_rule.value.redirect, "replace_key_with", null)
      }
    }
  }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "main" {
  count = var.bucket_policy != null ? 1 : 0

  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy
}

# Replication Configuration
resource "aws_s3_bucket_replication_configuration" "main" {
  count = var.enable_replication ? 1 : 0

  bucket = aws_s3_bucket.main.id
  role   = var.replication_role_arn

  dynamic "rule" {
    for_each = var.replication_rules
    content {
      id       = rule.value.id
      status   = rule.value.status
      priority = lookup(rule.value, "priority", 0)

      dynamic "filter" {
        for_each = lookup(rule.value, "prefix", null) != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      destination {
        bucket        = rule.value.destination_bucket
        storage_class = lookup(rule.value, "storage_class", "STANDARD")

        dynamic "encryption_configuration" {
          for_each = lookup(rule.value, "replica_kms_key_id", null) != null ? [1] : []
          content {
            replica_kms_key_id = rule.value.replica_kms_key_id
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = lookup(rule.value, "sse_kms_encrypted_objects", false) ? [1] : []
        content {
          sse_kms_encrypted_objects {
            status = "Enabled"
          }
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# Object Lock Configuration
resource "aws_s3_bucket_object_lock_configuration" "main" {
  count = var.enable_object_lock ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    default_retention {
      mode  = var.object_lock_mode
      days  = var.object_lock_days
      years = var.object_lock_years
    }
  }
}

# Intelligent Tiering
resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  count = var.enable_intelligent_tiering ? 1 : 0

  bucket = aws_s3_bucket.main.id
  name   = "EntireBucket"

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = var.intelligent_tiering_deep_archive_days
  }

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = var.intelligent_tiering_archive_days
  }
}

# Bucket Notification
resource "aws_s3_bucket_notification" "main" {
  count = length(var.lambda_notifications) > 0 || length(var.sns_notifications) > 0 || length(var.sqs_notifications) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = var.sns_notifications
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = var.sqs_notifications
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }
}

# CloudWatch Metrics
resource "aws_s3_bucket_metric" "main" {
  count = var.enable_metrics ? 1 : 0

  bucket = aws_s3_bucket.main.id
  name   = "EntireBucket"
}
