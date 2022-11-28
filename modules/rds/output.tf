output "db_address" {
    value = aws_db_instance.rds_db.address
}

output "db_endpoint" {
    value = aws_db_instance.rds_db.endpoint
}
