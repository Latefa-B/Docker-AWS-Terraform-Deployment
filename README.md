# Step-by-step Guide to Deploying Docker to AWS with Terraform
Deploying Docker to AWS (EC2) with Terraform involves combining the power of both tools, to deploy and automate modern containerized applications in a consistent, repeatable, efficient, secure and scalable way. Docker enables you to package your application and its dependencies into a lightweight, portable container, while Terraform automates the provisioning of cloud infrastructure using infrastructure as code (IaC). 
This comprehensive step-by-step guide walks you through the process of Deploying Docker to AWS with Terraform. This involves setting up a basic EC2 instance in AWS Cloud Provider, and setting up Docker and Docker Compose on the instance, using Terraform as an infrastructure as code tool. The project consists of two parts : 
- **Part 1** : we will explore how to deploy an EC2 instance using Terraform.
- **Part 2** : we will explore how to set up Docker and Docker compose in the EC2 Instance, using Terraform and run a multi-container Docker application on a remote server.

The aim of this project is to learn : 
- What Infrastructure as Code (IaC) is and why it's useful.
- How to set up AWS credentials for Terraform.
- How to write a basic Terraform configuration to create an EC2 instance.
- How to use Terraform commands (init, plan, apply) to manage cloud resources.
- How to connect to your EC2 instance using SSH.
- How to install Docker and Docker Compose on an EC2 instance automatically using Terraform user_data.
- How to transfer your application code to the EC2 instance.
- How to run your multi-container Docker application on a remote server.
- How to open necessary ports on your EC2 instance's Security Group for your application.

## Part 1 : Deploying an EC2 Instance on AWS with Terraform
### Prerequisites
- Have an AWS Account.
- Have deployed previously a multi-container Docker application and understand Docker basics.
- Have Docker, Terraform and AWS CLI Installed and Configured.

### Step-by-Step Instructions : 
#### Step 1: Create Your Terraform Configuration Files
Terraform uses .tf configuration files to define the infrastructure. For this application, we will create two files: a main.tf file to describe our server, and a variables.tf file to store some settings that might change. To complete Step 1, follow the instructions below : 
- Create a new folder on your computer named aws-docker-infra.
- Inside aws-docker-infra, create a new file named main.tf.
- Open main.tf with a text editor and paste the following content:




- In the same aws-docker-infra folder, create a new file named variables.tf.
- Open variables.tf with your text editor and paste the following content:

- Save both files. Your aws-docker-infra folder should now contain main.tf and variables.tf.



#### Step 2: Initialize Terraform
We have created our configuration files. In order to deploy the infrastructure with Terraform, we need to initialize the working directory using the command : Terraform init. It will download the necessary "provider" plugins (in our case, the AWS provider) that Terraform needs to interact with your cloud account. To complete Step 2, follow the instructions below : 

- Open your command line or terminal. Navigate to your aws-docker-infra folder and get inside it. Run terraform init command to initialize Terraform.

**Expected output** : You should see a message indicating that Terraform has been successfully initialized and the AWS provider plugin has been downloaded.



#### Step 3: Plan Your Infrastructure Changes
Before Terraform makes any changes to your AWS account, it is a good practice to run terraform plan command. It allows you to preview what changes will happen, before Terraform applies them. To complete Step 3, follow the instructions below : 
- In your aws-docker-infra folder, run the Terraform plan command to preview the changes.
**Expected output** : Terraform will output a detailed plan, showing you that it plans to add 7 resources : an EC2 instance, a security group and a VPC with its components. 






#### Step 4: Apply Your Infrastructure Changes
Now that we have previewed the changes with terraform plan command we can now "apply" them, with terraform apply command. This command applies the changes and builds the infrastructure. To complete Step 4, follow the instructions below : 
- In your aws-docker-infra folder, run terraform apply command. 
- Type yes when prompted.
**Expected output** : Terraform will start creating the resources in AWS. This might take a few minutes. Once complete, you will see a message like "Apply complete!" and the public IP address of your new EC2 instance will be displayed as an output.




- Check your infrastructure on the AWS Console. The VPC was created as well as its components : VPC, Public Subnet, Public Route Table and Internet Gateway, EC2 Instance : MyDockerServer and Security Group.
- **VPC**

- **Public Subnet, Public Route Table and Internet Gateway**

- **EC2 Instance : MyDockerServer**


- **Security Group**

#### Step 5: Connect to Your EC2 Instance via SSH
Now that your EC2 instance is running, you can connect to it securely using SSH (Secure Shell). This allows you to run commands on the remote server as if you were sitting in front of it. You'll need the .pem file for the SSH key pair you specified in variables.tf. To complete Step 5, follow the instructions below : 
- Open your command line or terminal and Navigate to the directory where your .pem file is saved.
- Run chmod 400 your-ssh-key-name.pem to set correct permissions for your key file.  This command makes sure only you can read the key file, which is a security best practice.
- Connect to your EC2 instance “MyDockerServer” using the ssh command using the command : ssh -i your-ssh-key-name.pem ubuntu@public_IP_adress.
- If prompted about "authenticity of host," type yes and press Enter.

**Expected output** : You should now be connected to your EC2 instance! You will see a command prompt like ubuntu@ip-XXX-XXX-XXX-XXX:~$ indicating you are on the remote server. Congratulations! You have successfully provisioned a server in AWS using Terraform and connected to it. In the next part, we will install Docker on this server and deploy our application.

## Part 2 : Deploying Docker and Docker Compose to the EC2 Instance with Terraform

### Prerequisites
- Have Docker, Terraform and AWS CLI Installed and Configured.
- Have successfully completed part 1 : An EC2 instance provisioned by Terraform, The SSH key (.pem file) for connecting to your EC2 instance. And your docker-compose-app folder from previous deployment ready.
- Ensure your AWS account and Terraform setup are still configured from previous deployment.
  
#### Step 1: Update Terraform Configuration to Install Docker and Docker Compose
Previously we have deployed an EC2 instance on AWS cloud using Terraform, in this second part of the lab we will set up Docker in the EC2. Instead of manually connecting to the EC2 instance and typing commands to install Docker and Docker Compose, we can tell Terraform to do it automatically when the server starts. We'll use a user_data script in main.tf for this. We also need to open the web application's port (5000) in the Security Group so users can access it. To complete Step 1, follow the instructions below : 
- Open your aws-docker-infra/main.tf file.
- Add the user_data block inside your aws_instance.web_server resource. This script will run when the EC2 instance first launches
- Add an ingress rule to your aws_security_group.allow_ssh resource to allow incoming traffic on port 5000 (our Flask app's port).
- Save main.tf.
- In the main.tf configuration file, we have previously defined the provider, the aws instance ‘web_server’ settings and a security group rule to allow ssh inbound traffic.  In this second part of the lab we are setting up docker on ubuntu OS using the user data feature, and adding a rule to the security group to allow inbound traffic custom TCP on port 5000.





#### Step 2: Apply Terraform Changes and Recreate EC2 Instance
Since we have changed the user_data script and the Security Group, Terraform needs to apply these changes. user_data only runs on initial launch, Terraform will detect that it needs to recreate the EC2 instance to apply the new user_data script. It will also update the Security Group. To complete Step 2, follow the instructions below : 
- Open your command line or terminal. Navigate to your aws-docker-infra folder.
- Run terraform plan to preview the expected changes. You should see that Terraform plans to destroy and then create a new EC2 instance, and modify the security group.

- Run terraform apply to apply the changes, If the plan looks correct. Type yes when prompted.
This process will take several minutes as Terraform destroys the old instance and provisions a new one, then runs the user_data script to install Docker. 






#### Step 3: Wait for Docker Installation and Reconnect
The user_data script includes a sudo reboot command at the end. This is important for the ubuntu user to be correctly added to the docker group, allowing you to run docker commands without sudo. After the reboot, you'll need to reconnect. To complete Step 3, follow the instructions below : 
- SSH into the EC2 instance MyDockerServer 
- After terraform apply finishes, wait for about 3-5 minutes. The EC2 instance needs time to boot up, run the user_data script, and then reboot. SSH into your new EC2 instance using its new public IP address (from the terraform apply output) and your .pem key using the command : ssh -i your-ssh-key-name.pem ubuntu@YOUR_NEW_PUBLIC_IP

- Once connected, verify Docker is installed and the ubuntu user can run Docker using the commands: docker --version, docker compose version and docker run hello-world

**Expected output** : You should see version numbers for Docker and Docker Compose. docker run hello-world should run successfully without sudo. If it fails, wait a bit longer and try again, or try sudo reboot on the EC2 instance and reconnect.


#### Step 4: Transfer Your Application to the EC2 Instance
Now that Docker is set up ready on your EC2 instance, we need to get our docker-compose-app (from Lab 3) onto the server. We will transfer the folder using the command scp (secure copy). To complete Step 4, follow the instructions below : 
- On your local terminal, Navigate to your home directory and run this command : scp -i your-ssh-key-name.pem -r docker-compose-app ubuntu@YOUR_NEW_PUBLIC_IP:~
- Breakdown of the command : 
**scp** : The secure copy command.
**i** your-ssh-key-name.pem: Specifies your SSH key.
**r** : Recursive, meaning copy the folder and all its contents.
**docker-compose-app** : The folder on your local machine to copy.
**ubuntu@YOUR_NEW_PUBLIC_IP:~** : The destination. ~ means the home directory of the ubuntu user on the EC2 instance.
**Expected output** : You should see output indicating files are being copied.

#### Step 5: Run Your Application on the EC2 Instance
Now that we have transferred the terraform application code on the EC2 instance, we will start the multi-container application using Docker Compose. To complete Step 5, follow the instructions below : 
- SSH into your EC2 instance using the command : ssh -i your-ssh-key-name.pem ubuntu@YOUR_NEW_PUBLIC_IP
- Navigate into the copied application folder and Run your Docker Compose application using the command : docker compose up -d --build
**Expected output** : This will build the Flask app image (if it hasn't been built on the EC2 instance before) and start both the web and db containers.

- Verify that both containers are running on the EC2 instance using the command : docker compose ps
**Expected output** : You should see both web and db services listed with a State of running.

- Access your application from your local web browser: Open your web browser. In the address bar, type : http://YOUR_NEW_PUBLIC_IP:5000
**Expected output** :  You should now see your "Simple Message Board" application running live in the cloud! Add some messages to confirm it's working. These messages are now stored in the database running on your EC2 instance.

#### Step 6 : Clean Up (Optional but Recommended)
Now that your infrastructure was deployed successfully, clean it up ! This prevents unnecessary charges. To complete Step 6, follow the instructions below : 
- Run terraform destroy command : to delete the infrastructure and remove all the resources managed by terraform.
- Type yes when prompted.
**Expected output** : Terraform will proceed to delete all the resources it created in your AWS account. Once complete, you will see a "Destroy complete!" message. This ensures you don't leave resources running and get charged.

- Check on the AWS console that your infrastructure was removed : the VPC and all its components were deleted.






#### Summary
This breakdown provides a step-by-step guide to Deploy Docker to AWS using Terraform. By completing this project, we had an overview on how to : 
Write Terraform code to provision AWS resources like VPC, subnets, internet gateway, EC2, security groups, and key pairs.
Configure user data scripts to install Docker and run containers at instance launch.
Organize Terraform code into separate files with a main.tf and a variables.tf configuration files to keep the code  clean, maintainable and reusable. 
Manage infrastructure as code, enabling consistent and scalable deployments.
Deploying Docker in AWS with Terraform as an IaC tool is an approach that combines two powerful DevOps tools that work together seamlessly to simplify and automate cloud-based deployments, making them a foundation in deploying containerized modern and complex applications like in real-world environments, for a fast, reliable and consistent deployment.
