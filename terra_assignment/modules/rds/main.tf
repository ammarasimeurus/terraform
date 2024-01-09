
variable "sg_name" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "publicly_accessible" {
  type = bool
}
variable "engine" {
  type = string
}
variable "public_subnet" {
}
variable "vpc_sg_id" {
}
variable "owner" {
  
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = var.sg_name
  subnet_ids = [var.public_subnet[0].id,var.public_subnet[1].id,var.public_subnet[2].id] # Replace with your subnet IDs
  tags = {
    Name = var.sg_name
  }
}

resource "aws_db_instance" "mydb" {
  identifier           = "${var.owner}-db-instance"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = var.engine
  engine_version       = "5.7"
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  publicly_accessible = var.publicly_accessible
  db_subnet_group_name = var.sg_name
  parameter_group_name = "default.mysql5.7"
  
  vpc_security_group_ids = [var.vpc_sg_id] # Replace with your security group ID

  final_snapshot_identifier = "mydb-snapshot"

  # Optional: Uncomment the following block for Multi-AZ deployment
  multi_az = true

  # Optional: Uncomment the following block for maintenance window configuration
  # maintenance_window = "Sun:05:00-Sun:09:00"

  # Optional: Uncomment the following block for backup window configuration
  # backup_window = "03:00-06:00"

  tags = {
    Name = "${var.owner}-db-instance"
  }
  depends_on = [ aws_db_subnet_group.mydb_subnet_group ]
}

output "endpoint" {
  value = aws_db_instance.mydb.endpoint
  }