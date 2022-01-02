#Do not use special characters as they broke wp-install.sh
resource "random_string" "mysql_password" {
  length  = 10
  special = false
}

resource "aws_db_instance" "aws_s23-mysql" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  port                   = "3306"
  identifier             = "mysqldb"
  identifier_prefix      = null
  multi_az               = false
  storage_encrypted      = false
  skip_final_snapshot    = true
  snapshot_identifier    = null
  username               = var.DB_USER
  password               = random_string.mysql_password.result
  name                   = var.DB_NAME
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet.id
  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]

  tags = {
    Name = "MySQL RDS Instance"
  }
}

# AWSAuthenticationPlugin supported only for Aurora
# provider "mysql" {
#   endpoint = aws_db_instance.aws_s23-mysql.endpoint
#   username = aws_db_instance.aws_s23-mysql.username
#   password = aws_db_instance.aws_s23-mysql.password
# }

# resource "mysql_user" "mysql-iam-user" {
#   provider    = mysql
#   user        = aws_iam_user.db_admin
#   host        = "%"
#   auth_plugin = "AWSAuthenticationPlugin"
#   tls_option  = "NONE"
# }
