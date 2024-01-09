// modules/vpc/main.tf
data "aws_availability_zones" "current" {}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cider
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = element(data.aws_availability_zones.current.names, count.index % length(data.aws_availability_zones.current.names))
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = element(data.aws_availability_zones.current.names, count.index % length(data.aws_availability_zones.current.names))
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_route_assoc" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_eip" "my_eip" {
  count = var.enable_nat_gateway ? 1 : 0
}
resource "aws_nat_gateway" "my_nat_gateway" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.my_eip[count.index].id
  subnet_id     = aws_subnet.public[0].id # Choose one of the public subnets for the NAT Gateway
  tags = {
    Name = "nat-gateway"
  }
}





resource "aws_route_table" "private_route_table" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "private_route" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[count.index].id
}

resource "aws_route_table_association" "private_route_assoc" {

  count          = var.enable_nat_gateway ? length(var.private_subnets_cidr) : 0
  subnet_id      = element(aws_subnet.private, count.index % length(aws_subnet.private)).id
  route_table_id = element(aws_route_table.private_route_table, count.index % length(aws_route_table.private_route_table)).id
}

resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.my_vpc.id



  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }


  // Allow outbound traffic to all destinations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Add a tag to identify the security group
  tags = {
    Name = "allow-selected-ports"
  }
}
// Output the VPC ID and public/private subnet IDs for reference

