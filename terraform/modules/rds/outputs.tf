output "rds_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.db.endpoint
}

output "rds_port" {
  description = "Port for the RDS instance"
  value       = aws_db_instance.db.port
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.db.arn
}

output "rds_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.db.id
}

output "rds_address" {
  description = "The DNS address of the RDS instance"
  value       = aws_db_instance.db.address
}
