resource "aws_security_group" "web-sg" {
  name   = "WP-SG"
  vpc_id = aws_vpc.aws_s23_vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.elb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WP-SG"
  }
}

resource "aws_security_group" "efs-sg" {
  name   = "EFS-SG"
  vpc_id = aws_vpc.aws_s23_vpc.id
  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.web-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-SG"
  }
}

resource "aws_security_group" "rds-sg" {
  name   = "RDS-SG"
  vpc_id = aws_vpc.aws_s23_vpc.id
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    #cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.web-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}

resource "aws_security_group" "elb-sg" {
  name   = "ELB-SG"
  vpc_id = aws_vpc.aws_s23_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ELB-SG"
  }
}
