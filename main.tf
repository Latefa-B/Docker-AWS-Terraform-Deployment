# Explanation: This block tells Terraform which cloud provider we want to use (AWS)
# and in which region (like a geographical area, e.g., us-east-1 for North Virginia).
# It also specifies the version of the AWS provider Terraform should use.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a compatible version
    }
  }
}

# Explanation: This block configures the AWS provider.
# It tells Terraform to use the AWS credentials already configured on your system
# (via AWS CLI) and specifies the region where resources will be created.
provider "aws" {
  region = var.aws_region # We'll define 'aws_region' in variables.tf
}

# Explanation: This block defines our EC2 instance (a virtual server).
# We give it a name, choose an Amazon Machine Image (AMI), and an instance type.
# We also assign a key pair for secure access and open port 22 for SSH.
resource "aws_instance" "web_server" {
  # Explanation: The AMI ID is like a template for our server.
  # This specific AMI is a free-tier eligible Ubuntu 22.04 LTS image for us-east-1.
  # You might need to change this if you are in a different region!
  # Always check the latest AMI for your region: https://cloud-images.ubuntu.com/locator/
  ami           = var.ami_id # Defined in variables.tf
  # Explanation: The instance type defines the size and power of our server.
  # 't2.micro' is generally free-tier eligible and good for small tasks.
  instance_type = "t2.micro"
  # Explanation: This is the name of the SSH key pair you will use to connect.
  # You must have this key pair already created in your AWS account in the chosen region.
  key_name      = var.key_pair_name # Defined in variables.tf
  subnet_id     = aws_subnet.public.id

  # Explanation: This block defines a security group, which acts like a firewall
  # for our EC2 instance. It controls what incoming and outgoing network traffic is allowed.
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # Explanation: Tags are labels that help organize and identify your resources in AWS.
  tags = {
    Name = "MyDockerServer"
    Project = "DockerLabs"
  }
 # Explanation: This 'user_data' script will run automatically when the EC2 instance starts.
 # It installs Docker, Docker Compose, and adds the 'ubuntu' user to the 'docker' group
 # so that Docker commands can be run without 'sudo
 user_data = <<-EOF
              #!/bin/bash
              echo "Updating apt packages..."
              sudo apt-get update -y

              echo "Installing Docker..."
              sudo apt-get install -y ca-certificates curl gnupg lsb-release
              sudo mkdir -m 0755 -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              echo "Adding ubuntu user to docker group..."
              sudo usermod -aG docker ubuntu

              echo "Docker installation complete. Rebooting to apply group changes..."
              sudo reboot
              EOF
}

# --- AWS ECR Repository ---
# Explanation: This block defines an Elastic Container Registry (ECR) repository.
# ECR is AWS's managed Docker image registry, similar to Docker Hub but private to your AWS account.
#resource "aws_ecr_repository" "app_repo" {
 # name                 = "my-flask-app-repo"
  #image_tag_mutability = "MUTABLE" # Allows 'latest' tag to be overwritten
  # Explanation: Image scanning on push checks for security vulnerabilities in your images.
  #image_scanning_configuration {
   # scan_on_push = true
  #}
  #tags = {
   # Name = "my-flask-app-repo"
  #}
#}

# --- IAM Role for CodeBuild ---
# Explanation: CodeBuild needs permissions to access ECR, CloudWatch Logs, etc.
# An IAM Role defines these permissions.
#resource "aws_iam_role" "codebuild_role" {
 # name = "codebuild-my-flask-app-role"

  #assume_role_policy = jsonencode({
   # Version = "2012-10-17"
    #Statement = [
     # {
      #  Action = "sts:AssumeRole"
       # Effect = "Allow"
        #Principal = {
         # Service = "codebuild.amazonaws.com"
        #}
     # },
    #]
 # })
#}

# Explanation: This attaches a policy to the IAM Role, giving it specific permissions.
#resource "aws_iam_role_policy" "codebuild_policy" {
 # role = aws_iam_role.codebuild_role.name

  #policy = jsonencode({
   # Version = "2012-10-17"
    #Statement = [
     # {
        # Explanation: Allow CodeBuild to push images to our ECR repository.
      #  Action = [
       #   "ecr:BatchCheckLayerAvailability",
        #  "ecr:CompleteLayerUpload",
         # "ecr:GetDownloadUrlForLayer",
          #"ecr:InitiateLayerUpload",
          #"ecr:PutImage",
        #  "ecr:UploadLayerPart"
        #]
        #Effect = "Allow"
        #Resource = aws_ecr_repository.app_repo.arn
      #},
      #{
        # Explanation: Allow CodeBuild to get ECR authentication tokens.
       # Action = [
        #  "ecr:GetAuthorizationToken"
        #]
        #Effect = "Allow"
        #Resource = "*" # This action requires "*" resource
      #},
     # {
        # Explanation: Allow CodeBuild to write logs to CloudWatch.
      #  Action = [
       #   "logs:CreateLogGroup",
        #  "logs:CreateLogStream",
         # "logs:PutLogEvents"
        #]
        #Effect = "Allow"
        #Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.app_build.name}"
     # },
      #{
        # Explanation: Allow CodeBuild to read from S3 (if source is S3, or for cache).
       # Action = [
        #  "s3:GetObject",
         # "s3:GetObjectVersion",
          #"s3:PutObject" # For cache
        #]
        #Effect = "Allow"
        #Resource = "*" # Adjust if you use specific S3 buckets
      #}
    #]
  #})
#}

# Explanation: Data source to get current AWS account ID for ARN construction.
data "aws_caller_identity" "current" {}

# --- AWS CodeBuild Project ---
# Explanation: This block defines our CodeBuild project.
#resource "aws_codebuild_project" "app_build" {
 # name          = "my-flask-app-build"
  #description   = "Builds and pushes Docker image for my-flask-app"
  #service_role  = aws_iam_role.codebuild_role.arn
  #build_timeout = "5" # minutes
  #source_version = "latefa-branch"

  # Explanation: Defines where CodeBuild gets its source code.
  #source {
   # type            = "GITHUB" # Or "CODECOMMIT", "S3", etc.
    #location        = var.github_repo_url # Defined in variables.tf
    #buildspec       = "buildspec.yml" # The file we created in Step 1
    #git_clone_depth = 1 # Only clone the latest commit
    #report_build_status = true

    #git_submodules_config {
     # fetch_submodules = false
    #}
  #}
  # Explanation: Defines the build environment (compute, image).
  #environment {
    #compute_type                = "BUILD_GENERAL1_SMALL" # Or MEDIUM, LARGE
    #image                       = "aws/codebuild/standard:6.0" # A standard CodeBuild image
    #type                        = "LINUX_CONTAINER"
    #privileged_mode             = true # Required for building Docker images
    # Explanation: Environment variables passed to the build.
    # ECR_REPOSITORY_URI is used in buildspec.yml to know where to push the image.
    #environment_variable {
     # name  = "ECR_REPOSITORY_URI"
    #  value = aws_ecr_repository.app_repo.repository_url
   # }
  #}
  # FIX: Add artifacts block to avoid error
  #artifacts {
   # type = "NO_ARTIFACTS"
  #}
  # Explanation: Where build logs are sent.
  #logs_config {
    #cloudwatch_logs {
     # group_name  = "/aws/codebuild/${var.codebuild_project_name}" # Defined in variables.tf
    #  stream_name = "build-log-stream"
   # }
  #}

  #tags = {
  #  Name = "my-flask-app-build"
 # }
#}

  
# Explanation: This block defines the security group that allows SSH access.
# SSH (Secure Shell) is how we will securely connect to our server from our computer.
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_from_everywhere"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id # Associate with our default VPC

  # Explanation: This rule allows incoming traffic on port 22 (SSH) from any IP address (0.0.0.0/0).
  # In a real environment, you would restrict this to your specific IP address for better security.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be careful: allows SSH from anywhere!
  }
  # Explanation: This new rule allows incoming HTTP traffic on port 5000 from anywhere.
  # This is for our Flask web application.
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows access to our web app from anywhere
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh_sg"
  }
}

# Explanation: This block defines a default VPC (Virtual Private Cloud)
# if one doesn't already exist or if we want to explicitly create one.
# For simplicity, we'll assume a default VPC.
# If you already have a default VPC, you might adjust this or remove it.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "my-default-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "PublicSubnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "InternetGateway" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "PublicRoute" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# Explanation: This block exports the public IP address of our EC2 instance.
# This is the address you will use to connect to your server.
output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}
