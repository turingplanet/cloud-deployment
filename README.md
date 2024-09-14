# Cloud Deployment Setup Documentation

## Prerequisites
* [Set up an Amazon AWS account](https://aws.amazon.com/)
* Create [ECR repositories](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html) for both backend and frontend
* Clone the following repositories into your local machine:
   ```
   git clone https://github.com/turingplanet/unified-api-docker.git
   git clone https://github.com/turingplanet/react-frontend-docker.git
   git clone https://github.com/turingplanet/cloud-deployment.git
   ```
* [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Set up EC2 Instance
1.  Generate an SSH key pair under [the terraform folder path](https://github.com/turingplanet/cloud-deployment/tree/main/terraform) by running:
    ```
    ssh-keygen -t rsa -b 2048 -f ./id_rsa
    ```

2.  Navigate to [the terraform directory](https://github.com/turingplanet/cloud-deployment/tree/main/terraform) and run the following commands:
    ```
    terraform init
    terraform apply
    ```
    This will initialize the Terraform working directory and then create or update your infrastructure, including deploying your EC2 instance.

3. Once the EC2 instance is launched, SSH into it:
   ```
   ssh -i id_rsa ec2-user@<your_ec2_ip_address>
   ```

4. Copy the content of [ec2_build.sh](https://github.com/turingplanet/cloud-deployment/blob/main/script/ec2_build.sh) to your EC2 instance and edit it to configure AWS and install Docker. Remember to replace the placeholder [AWS_ACCESS_KEY_ID](https://github.com/turingplanet/cloud-deployment/blob/main/script/ec2_build.sh#L4) and [AWS_SECRET_ACCESS_KEY](https://github.com/turingplanet/cloud-deployment/blob/main/script/ec2_build.sh#L5) with your own [credentials](https://docs.aws.amazon.com/sdkref/latest/guide/feature-static-credentials.html) in the script. Then execute the script.
    ```
    chmod +x ec2_build.sh
    ./ec2_build.sh
    ```

5. Set up Docker Compose by running:
   ```
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

## Backend API Deployment
1. In the [build_and_push.sh](https://github.com/turingplanet/unified-api-docker/blob/main/build_and_push.sh) file, replace [AWS_REGION](https://github.com/turingplanet/unified-api-docker/blob/main/build_and_push.sh#L4), [AWS_ACCOUNT_ID](https://github.com/turingplanet/unified-api-docker/blob/main/build_and_push.sh#L5), and [ECR_REPOSITORY](https://github.com/turingplanet/unified-api-docker/blob/main/build_and_push.sh#L6) with your correct AWS settings.

2. Run [build_and_push.sh](https://github.com/turingplanet/unified-api-docker/blob/main/build_and_push.sh) locally to build the Docker image and push it to ECR. Before running the script, update [the secret.yml](https://github.com/turingplanet/unified-api-docker/blob/main/secret.yml) file with your OpenAI API key.

3. Create a docker-compose.yml file in EC2 and copy the content from [ec2-docker-compose.yml](https://github.com/turingplanet/unified-api-docker/blob/main/ec2-docker-compose.yml). Remember to replace the OPENAI_API_KEY value with your own OpenAI API key and update the [image name](https://github.com/turingplanet/unified-api-docker/blob/main/ec2-docker-compose.yml#L16) to use your correct AWS account ID and ECR repository.

4. Pull your backend ECR repository and run Docker Compose:
   ```
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your_aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
   docker-compose up --pull always -d
   ```

5. Run [the upload_db_data.sh](https://github.com/turingplanet/cloud-deployment/blob/main/script/upload_db_data.sh) script locally to upload your MongoDB data to the EC2 instance. 
    * Replace [IP_ADDRESS](https://github.com/turingplanet/cloud-deployment/blob/main/script/upload_db_data.sh#L4) with the public IP address of your EC2 instance.
    * Replace [LOCAL_DUMP_PATH](https://github.com/turingplanet/cloud-deployment/blob/main/script/upload_db_data.sh#L10) with the full path to your local MongoDB dump directory.

6. Test your API by accessing `http://<ec2_ip_address>:5001/api/news_sentiment?symbol=TSLA&sort_field=time_published&sort_order=desc` in your browser.

## Frontend Setup

1. Replace [API_BASE_URL](https://github.com/turingplanet/react-frontend-docker/blob/main/src/components/utils/config.js#L1) in [config.js](https://github.com/turingplanet/react-frontend-docker/blob/main/src/components/utils/config.js#L1) with your EC2 instance's public IP address.

2. Build the frontend Docker image and push it to ECR locally using the [build_and_push.sh script](https://github.com/turingplanet/react-frontend-docker/blob/main/build_and_push.sh). Remember to replace AWS_REGION, AWS_ACCOUNT_ID, and ECR_REPOSITORY with your correct AWS settings in the script before running it.

3. Pull and run your frontend image from ECR:
   ```
   docker pull <your_aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/stock_platform_react_frontend:latest
   docker run -d -p 3000:3000 <your_aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/stock_platform_react_frontend:latest
   ```

4. Access your website by navigating to `http://<ec2_ip_address>:3000` in your browser.

