resource "aws_vpc" "aws_s23_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws_s23_vpc"
  }
}

resource "aws_subnet" "aws_s23_subnet_az" {
  count                   = length(var.subnet_cidrs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.aws_s23_vpc.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.az_list[count.index]
  tags = {
    Name = "subnet_az_${var.az_list[count.index]}"
  }
}

resource "aws_db_subnet_group" "rds-subnet" {
  name       = "rds-subnet"
  subnet_ids = aws_subnet.aws_s23_subnet_az[*].id

  tags = {
    Name = "rds-subnet"
  }
}

resource "aws_internet_gateway" "aws_s23-gw" {
  vpc_id = aws_vpc.aws_s23_vpc.id
}

resource "aws_route_table" "aws_s23-rt" {
  vpc_id = aws_vpc.aws_s23_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_s23-gw.id
  }

  tags = {
    Name = "aws_s23-rt"
  }
}

resource "aws_main_route_table_association" "aws_s23-rt-association" {
  vpc_id         = aws_vpc.aws_s23_vpc.id
  route_table_id = aws_route_table.aws_s23-rt.id
}
