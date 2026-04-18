# 'us-east-1' is a common choice (N. Virginia).
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Explanation: This variable holds the AMI ID for your EC2 instance.
# IMPORTANT: This AMI is for Ubuntu 22.04 LTS in us-east-1.
# If you use a different region, you MUST find the correct AMI ID for that region.
# Search for "Ubuntu 22.04 LTS AMI ID <your-region>" or use the Ubuntu Cloud Images locator.
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-020cba7c55df1f615" # Ubuntu 22.04 LTS for us-east-1
}

# Explanation: This variable holds the name of your SSH key pair in AWS.
# You MUST create an SSH key pair in your AWS account (EC2 -> Key Pairs)
# and provide its name here. This key is used to connect to your EC2 instance.
variable "key_pair_name" {
  description = "The name of the SSH key pair to use for the EC2 instance"
  type        = string
  # IMPORTANT: Replace "your-ssh-key-name" with the actual name of your key pair in AWS!
  default     = "new-key"
}
