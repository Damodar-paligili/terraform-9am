resource "random_password" "redis_auth_token" {
  length           = 40
  special          = true
  override_special = "!&#$^<>-"
}

resource "aws_secretsmanager_secret" "redis_auth_token" {
  name                    = "prod-data-production/redis/auth-token-v2"
  kms_key_id              = aws_kms_key.data.arn
  recovery_window_in_days = 30

  tags = {
    Name = "${local.name_prefix}-redis-auth-token"
  }
}

resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  secret_id     = aws_secretsmanager_secret.redis_auth_token.id
  secret_string = random_password.redis_auth_token.result
}

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${local.name_prefix}-redis7-v2"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${local.name_prefix}-redis-v2"
  description          = "Production Redis replication group for ${local.name_prefix}"

  engine         = "redis"
  engine_version = var.redis_engine_version
  node_type      = var.redis_node_type
  port           = 6379

  num_node_groups         = 1
  replicas_per_node_group = var.redis_replicas_per_node_group

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  parameter_group_name = aws_elasticache_parameter_group.redis.name

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.data.arn
  auth_token                 = random_password.redis_auth_token.result

  automatic_failover_enabled = true
  multi_az_enabled           = true

  snapshot_retention_limit = var.redis_snapshot_retention_days
  snapshot_window          = "01:00-02:00"
  maintenance_window       = "sun:02:00-sun:03:00"

  auto_minor_version_upgrade = true
  apply_immediately          = false

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name = "${local.name_prefix}-redis"
  }
}

resource "aws_cloudwatch_log_group" "redis_engine" {
  name              = "/aws/elasticache/${local.name_prefix}/redis-engine"
  retention_in_days = 30
  #kms_key_id        = aws_kms_key.data.arn

  tags = {
    Name = "${local.name_prefix}-redis-engine-logs"
  }
}

