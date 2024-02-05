/*
######################## IGNORE FOR NOW #####################################

resource "aws_db_subnet_group" "example_subnet_group" {
  name       = "example-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
}

resource "aws_security_group" "example_db_sg" {
  name        = "example-db-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere (for demo purposes, you may restrict to specific IP ranges)
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "2-sAD-sACK"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.example_subnet_group.name
  vpc_security_group_ids = [aws_security_group.example_db_sg.id]
}

output "rds_endpoint" {
  value = aws_db_instance.example_db.endpoint
}
*/
