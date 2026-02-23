# 1. Define the Cloud Provider and Region
provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# 2. Create the Virtual Private Cloud (The Main Network)
resource "aws_vpc" "main_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Enterprise-API-VPC"
  }
}

# 3. Create a Public Subnet (Where the Load Balancer will sit)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_network.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "Enterprise-Public-Subnet-1"
  }
}

# 4. Create an Internet Gateway (To connect your network to the outside world)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_network.id

  tags = {
    Name = "Enterprise-IGW"
  }
}

# 5. Create a Security Group (The Firewall)
resource "aws_security_group" "web_sg" {
  name        = "Enterprise-Web-SG"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main_network.id

  # Ingress: Allow HTTP web traffic from anywhere
  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: Allow SSH access for debugging
  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow the server to send data out to anywhere (like MongoDB)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Enterprise-Web-Security-Group"
  }
}

# 6. Get the latest Ubuntu 22.04 AMI (The OS Image) automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (The company that makes Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 7. Create the EC2 Instance (The Server)
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Free Tier Eligible!
  
  # Connect it to the network and firewall we built
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "enterprise-key" # Must match the name you created in Step 1

  # The "User Data" Script - Runs on first boot
  user_data = <<-EOF
              #!/bin/bash
              echo "Server is booting..."
              sudo apt-get update -y
              sudo apt-get install -y nodejs npm
              echo "Node.js installed!"
              EOF

  tags = {
    Name = "Enterprise-Node-Server"
  }
}

# 8. Output the Public IP so we can see it
output "server_public_ip" {
  value = aws_instance.app_server.public_ip
}

# 9. Create a Route Table (The Map to the Internet)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_network.id

  route {
    cidr_block = "0.0.0.0/0" # Send all outside traffic...
    gateway_id = aws_internet_gateway.igw.id # ...to the Internet Gateway
  }

  tags = {
    Name = "Enterprise-Public-Route-Table"
  }
}

# 10. Associate the Route Table with the Subnet (Plug it in)
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}