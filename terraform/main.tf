#Available AZs list in current AWS region
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC resources
resource "aws_vpc" "CICD-VPC" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "CICD-VPC",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_internet_gateway" "CICD-IGW" {
  vpc_id = aws_vpc.CICD-VPC.id

  tags = merge(
    {
      Name        = "CICD-IGW",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.CICD-VPC.id

  tags = merge(
    {
      Name        = var.private_route_table_name[count.index],
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route" "private" {
  count = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.CICD-NAT[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.CICD-VPC.id

  tags = merge(
    {
      Name        = "CICD-PublicRouteTable",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.CICD-IGW.id
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.CICD-VPC.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name        = var.private_subnets_name[count.index],
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.CICD-VPC.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = var.public_subnets_name[count.index],
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT resources
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)

  vpc = true
}

resource "aws_nat_gateway" "CICD-NAT" {
  depends_on = [aws_internet_gateway.CICD-IGW]

  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name        = "CICD-NAT",
      Project     = var.project
    },
    var.tags
  )
}
