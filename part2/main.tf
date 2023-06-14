#https://www.youtube.com/watch?v=q5AMMIpYnMI&list=PL21dI-erNM7c954KHtaiqj0oftWf1eZOg&index=2
resource "aws_vpc" "taxi_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "taxi_app"
  }
}
#----------Public----------------
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.taxi_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.taxi_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "public2"
  }
}

resource "aws_internet_gateway" "taxi_gw" {
  vpc_id = aws_vpc.taxi_vpc.id

  tags = {
    Name = "taxi_igw"
  }
}

resource "aws_route_table" "public_routing" {
  vpc_id = aws_vpc.taxi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.taxi_gw.id
  }

  tags = {
    Name = "public_routing_table"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_routing.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_routing.id
}


#----------------------Private-----------------------
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.taxi_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.taxi_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "private2"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.taxi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "private1_routing_table"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.taxi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "private2_routing_table"
  }
}


resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "NAT1"
  }
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "NAT2"
  }
}

resource "aws_eip" "nat1" {
  vpc      = true
}

resource "aws_eip" "nat2" {
  vpc      = true
}