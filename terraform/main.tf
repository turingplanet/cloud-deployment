# Provider configuration
provider "aws" {
  region = "us-east-1"  
}

# Create a security group in the default VPC
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add rule for HTTP traffic on port 3000
  ingress {
    description = "HTTP on port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Add rule for HTTP traffic on port 3000
  ingress {
    description = "HTTP on port 5001"
    from_port   = 5001 
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# Generate a key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# Launch EC2 instance in the default VPC
resource "aws_instance" "web" {
  ami           = "ami-0ae8f15ae66fe8cda"  # Amazon Linux 
  instance_type = "t3.large"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  root_block_device {
    volume_size = 20  # Set the root volume size to 20GB
  }

  tags = {
    Name = "StockInfoPlatform"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}
