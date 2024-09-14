#!/bin/bash

# Set the IP address as a variable
IP_ADDRESS="44.203.239.180"

# Set the path to your private key
PRIVATE_KEY="../terraform/id_rsa"

# Set the local path of your MongoDB dump
LOCAL_DUMP_PATH="/Users/full-stack-project/unified-api-docker/mongodb_dump/*"

# Create directory and set permissions
ssh -i $PRIVATE_KEY ec2-user@$IP_ADDRESS "sudo mkdir -p /home/ec2-user/mongodb_dump/StockInfoDB && sudo chown ec2-user:ec2-user /home/ec2-user/mongodb_dump /home/ec2-user/mongodb_dump/StockInfoDB"

# Copy MongoDB dump files
scp -i $PRIVATE_KEY -r $LOCAL_DUMP_PATH ec2-user@$IP_ADDRESS:/home/ec2-user/mongodb_dump/

# Connect to EC2 instance and restore MongoDB
ssh -i $PRIVATE_KEY ec2-user@$IP_ADDRESS << EOF
    docker-compose exec mongo mongorestore -u root -p example --authenticationDatabase admin /mongodb_dump
EOF

echo "MongoDB restore process completed."
