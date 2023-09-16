resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids                            = [for subnet in aws_subnet.private_subnets : subnet.id]
}
resource "aws_db_instance" "postgres" {
    identifier                            = "postgres"
    allocated_storage                     = 5
    backup_retention_period               = 2
    backup_window                         = "01:00-01:30"
    maintenance_window                    = "sun:03:00-sun:03:30"
    engine                                = "postgres"
    engine_version                        = "14"
    instance_class                        = var.db_instance_class
    username                              = aws_secretsmanager_secret_version.database_username_version.arn
    password                              = aws_secretsmanager_secret_version.database_password_version.arn
    port                                  = "5432"
    db_subnet_group_name                  = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids                = [aws_security_group.rds_sg.id, aws_security_group.ecs_sg.id]
    skip_final_snapshot                   = true
    final_snapshot_identifier             = "worker-final"
    publicly_accessible                   = false
}

