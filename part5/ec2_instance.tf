resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Public security group"
  vpc_id      = aws_vpc.taxi_vpc.id

  ingress {
    description      = "SSH from public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.enduser_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}

resource "aws_instance" "public" {
  ami           = "ami-06633e38eb0915f51" # us-west-2
  instance_type = "t3.micro"
  associate_public_ip_address = true
  key_name = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id = aws_subnet.public[0].id

  depends_on = [local_file.tf-key]

  tags = {
    Name = "${var.env_code}-public"
  }
}