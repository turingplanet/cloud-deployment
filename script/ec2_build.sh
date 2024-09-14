#!/bin/bash

# Setting AWS credentials and configuration non-interactively
AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
AWS_DEFAULT_REGION="us-east-1"

# Configure AWS Access Key, Secret Key, and Default Region
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"

echo "AWS configuration set successfully."

# Update system
sudo dnf upgrade -y

# Install and setup Docker
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker

# Wait for Docker to be ready
sleep 5

# Docker login (moved after Docker installation)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 132677503276.dkr.ecr.us-east-1.amazonaws.com

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Setup completed successfully."
