output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.main.id
}

output "app_security_group_id" {
  description = "Attach this security group to app servers/Lambda/ECS tasks that need DB and Redis access."
  value       = aws_security_group.app.id
}

output "rds_primary_endpoint" {
  description = "Primary RDS endpoint for writes."
  value       = aws_db_instance.primary.endpoint
}

output "rds_read_replica_endpoint" {
  description = "Read replica endpoint for read-only queries."
  value       = aws_db_instance.read_replica.endpoint
}

#output "rds_master_user_secret_arn" {
 # description = "Secrets Manager ARN containing the RDS master user password."
 # value       = aws_db_instance.primary.master_user_secret[0].secret_arn
 # sensitive   = true
#}

output "redis_primary_endpoint" {
  description = "Primary Redis endpoint."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint."
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_auth_token_secret_arn" {
  description = "Secrets Manager ARN containing the Redis auth token."
  value       = aws_secretsmanager_secret.redis_auth_token.arn
  sensitive   = true
}

