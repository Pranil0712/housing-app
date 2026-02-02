provider "aws" {
  region = "us-east-1"
}

# --- PART 1: NETWORK (Required to fix "No subnets found" error) ---
resource "aws_vpc" "housing_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Housing-VPC"
  }
}

resource "aws_subnet" "housing_subnet" {
  vpc_id                  = aws_vpc.housing_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Housing-Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.housing_vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.housing_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.housing_subnet.id
  route_table_id = aws_route_table.rt.id
}

# --- PART 2: SECURITY GROUP ---
resource "aws_security_group" "web_sg" {
  name        = "housing-sg"
  description = "Allow SSH, HTTP, and Jenkins"
  vpc_id      = aws_vpc.housing_vpc.id # Linked to our new VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- PART 3: SERVER INSTANCE ---
resource "aws_instance" "app_server" {
  ami           = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS (US-East-1)
  instance_type = "t2.medium"
  
  # WE ARE USING YOUR EXISTING KEY HERE
  key_name      = "devops-project-key" 
  
  subnet_id              = aws_subnet.housing_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Housing-DevOps-Server"
  }
}

output "server_ip" {
  value = aws_instance.app_server.public_ip
}