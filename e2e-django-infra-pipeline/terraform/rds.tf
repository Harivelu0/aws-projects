#aws subnets rds
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "${var.project_name}-rds-subnet-group"

  }
}


resource "aws_db_instance" "mysql" {
  identifier              = "${var.project_name}-rds"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  multi_az                = false
  publicly_accessible     = false
  storage_encrypted       = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  tags = {
    Name = "${var.project_name}-rds"
  }

}