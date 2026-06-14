# Production RDS With Read Replica And ElastiCache

This example creates:

- A private VPC with three private subnets.
- Security groups that allow MySQL and Redis only from the application security group.
- Encrypted MySQL RDS primary instance with Multi-AZ, backups, enhanced monitoring, Performance Insights, and AWS-managed master password in Secrets Manager.
- Encrypted MySQL read replica for read traffic.
- Encrypted Redis ElastiCache replication group with automatic failover, Multi-AZ, backups, auth token, and CloudWatch engine logs.

## Usage

Copy the example variables and adjust values for your account:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Attach the output `app_security_group_id` to your EC2 instance, ECS service, Lambda function, or other compute layer that needs access to RDS and Redis.

For real production, also connect these private subnets to your existing application VPC, observability stack, CI/CD pipeline, and backup/restore runbooks.

