provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

# Define two subnets in different availability zones
resource "aws_subnet" "subnet_a" {
  vpc_id                  = "your-vpc-id"  # Specify your VPC ID
  cidr_block              = "10.0.1.0/24"  # Specify the CIDR block for the subnet
  availability_zone        = "us-east-1a"  # Specify the availability zone
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = "your-vpc-id"  # Specify your VPC ID
  cidr_block              = "10.0.2.0/24"  # Specify the CIDR block for the subnet
  availability_zone        = "us-east-1b"  # Specify the availability zone
}

# Create two NAT gateways, each in a different subnet
resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_instance.nat_instance_a.network_interface_ids[0]
  subnet_id     = aws_subnet.subnet_a.id
}

resource "aws_nat_gateway" "nat_gateway_b" {
  allocation_id = aws_instance.nat_instance_b.network_interface_ids[0]
  subnet_id     = aws_subnet.subnet_b.id
}

# Create two EC2 instances to act as NAT gateways
resource "aws_instance" "nat_instance_a" {
  ami                    = "ami-xxxxxxxxxxxxxxxxx"  # Specify the NAT instance AMI ID
  instance_type          = "t2.micro"  # Specify the instance type for the NAT instance
  key_name               = "your-key-pair"  # Specify your key pair name
  subnet_id              = aws_subnet.subnet_a.id
  associate_public_ip_address = true  # Associates a public IP address with the NAT instance

  tags = {
    Name = "nat-instance-a"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo 1 > /proc/sys/net/ipv4/ip_forward
              echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF
}

resource "aws_instance" "nat_instance_b" {
  ami                    = "ami-xxxxxxxxxxxxxxxxx"  # Specify the NAT instance AMI ID
  instance_type          = "t2.micro"  # Specify the instance type for the NAT instance
  key_name               = "your-key-pair"  # Specify your key pair name
  subnet_id              = aws_subnet.subnet_b.id
  associate_public_ip_address = true  # Associates a public IP address with the NAT instance

  tags = {
    Name = "nat-instance-b"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo 1 > /proc/sys/net/ipv4/ip_forward
              echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF
}
