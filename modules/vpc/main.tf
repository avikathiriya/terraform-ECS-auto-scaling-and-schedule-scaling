
# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# -------------------------
# Public Subnet 1
# -------------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-1"
  }
}

# -------------------------
# Public Subnet 2
# -------------------------
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-2"
  }
}

# -------------------------
# Private Subnet 1
# -------------------------
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-1"
  }
}

# -------------------------
# Private Subnet 2
# -------------------------
resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-2"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# -------------------------
# Public Route Table
# -------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Elastic IPs for NAT Gateways
# -------------------------
resource "aws_eip" "nat_1" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-1"
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-2"
  }
}

# -------------------------
# NAT Gateway 1 in Public AZ 1
# -------------------------
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.my_igw]

  tags = {
    Name = "${var.vpc_name}-nat-1"
  }
}

# -------------------------
# NAT Gateway 2 in Public AZ 2
# -------------------------
resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  depends_on = [aws_internet_gateway.my_igw]

  tags = {
    Name = "${var.vpc_name}-nat-2"
  }
}

# -------------------------
# Private Route Table 1
# Routes through NAT Gateway 1
# -------------------------
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt-1"
  }
}

# -------------------------
# Private Route Table 2
# Routes through NAT Gateway 2
# -------------------------
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt-2"
  }
}

# Associate Private Subnets with Their Route Tables
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}
