#https://www.youtube.com/watch?v=HiTJyeFpJ40&list=PL21dI-erNM7c954KHtaiqj0oftWf1eZOg&index=3

resource "aws_vpc" "taxi_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env_code
  }
}
#----------Public----------------
resource "aws_subnet" "public" {
  count = 2

  vpc_id     = aws_vpc.taxi_vpc.id
  cidr_block = var.public_cidr[count.index]

  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.env_code}-public${count.index+1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.taxi_vpc.id

  tags = {
    Name = "${var.env_code}-IGW"
  }
}

resource "aws_route_table" "public_routing" {
  vpc_id = aws_vpc.taxi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env_code}-Public-Route_Table"
  }
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_routing.id

}


#----------------------Private-----------------------
resource "aws_subnet" "private" {
  count = 2
  vpc_id     = aws_vpc.taxi_vpc.id
  cidr_block = var.private_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.env_code}-private${count.index+1}"
  }
}

resource "aws_route_table" "private" {
  count = 2
  vpc_id = aws_vpc.taxi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private${count.index+1}_routing_table"
  }
}


resource "aws_route_table_association" "private1" {
  count = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_nat_gateway" "nat" {
  count = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env_code}-NAT-GW${count.index+1}"
  }
}


resource "aws_eip" "nat" {
  count = 2
  vpc      = true

  tags = {
    Name = "${var.env_code}-NAT_EIP${count.index+1}"
  }
}