resource "aws_vpc" "vpc_pipelines" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "vpc-pipelines"
  }
}


resource "aws_subnet" "subnet_public" {
  vpc_id            = aws_vpc.vpc_pipelines.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public"
  }
}
resource "aws_subnet" "subnet_private" {
  vpc_id            = aws_vpc.vpc_pipelines.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "subnet-private"
  }
}


resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.vpc_pipelines.id
}
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_public.id
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_pipelines.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_pipelines.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}



resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.private_rt.id
}










