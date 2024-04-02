# Terraform Infrastructure as Code (IaC) for EKS Cluster

This repository contains Terraform code to provision an Amazon Elastic Kubernetes Service (EKS) cluster on AWS. The IaC script includes configuration for the VPC, security groups, IAM roles, and more.

## Prerequisites

Before using this Terraform script, make sure you have the following prerequisites:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- `kubectl` for managing your Kubernetes cluster.
- AWS CLI configured with the necessary credentials.
- A basic understanding of Terraform and AWS services.

## Cost (Deprecated)

- Estimated EC2 Monthly cost: 12,406.54 USD
- Estimated EC2 10 Days cost: 4,135.51 USD
- Total vCPU and Memory: 296 vCPU 592 GB
- Total Disk: 18.94 TB

## Usage

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/iwillbeacloudguru/terraform-eks.git
   cd terraform-eks
   ```

2. Create a terraform.tfvars file based on your requirements. Here's an example:

   ```bash
   ### terraform.tfvars ###
   aws_region = "ap-southeast-1"
   project_name = "eks-dev"
   cluster_version = "1.28"

   # Comment this if you don't use named profile in aws configure
   profile = "AdministratorAccess-xxxxx"

   # Adjust Sizing in this section
   node_size = "t3.large"
   node_number = 3
   disk_size = 32

   ami_type = "AL2_x86_64"
   node_type = "ON_DEMAND"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the plan:
   ```bash
   terraform plan -out tfout
   ```
5. Apply the configuration:
   ```bash
   terraform apply "tfout"
   ```
6. After provisioning is complete, you can access your EKS cluster and manage it using kubectl and Helm. Make sure to configure your kubectl and Helm with the provided credentials in your Terraform configuration.
   ```bash
   aws eks update-kubeconfig --name <cluster-name>
   or
   aws eks update-kubeconfig --name <cluster-name> --profile <aws configure profile>
   ```
7. Try to use the Kubernetes API to get information about your workload. You can beautify the results with kubectl:
   ```bash
   kubectl get all -A -o wide
   ```

## Deploy your workload and ingress

1. Change to the ./test directory.

2. Run the following command to deploy a namespace, deployment, service, and ingress:

   ```bash
   sh echoserver.sh
   ```

3. Run an AWS CLI command to get the ALB DNS. Replace <cluster-name> and <alb-name> with the appropriate values:

   ```bash
   aws eks describe-cluster --name <cluster-name> --query "cluster.resourcesVpcConfig.clusterSecurityGroup" --output text
   aws ec2 describe-security-groups --group-ids <security-group-id> --query "SecurityGroups[0].GroupName" --output text
   aws elbv2 describe-load-balancers --name <alb-name> --query "LoadBalancers[0].DNSName" --output text
   ```
     >Remember to replace <cluster-name> with the actual name of your EKS cluster, <security-group-id> with the security group associated with your EKS cluster, and <alb-name> with the name of your ALB. These AWS CLI commands will help you obtain the ALB DNS to access your application.
4. After obtaining the ALB DNS, use the following curl command to access your deployed workload. Replace <alb-dns> and <path> with the actual values:
    ```bash
    curl http://<alb-dns>/<path>
    ```
    Where:
    <b>alb-dns</b> is the DNS name of your Application Load Balancer.
    <b>path</b> is the path to your deployed application.


## Cleanup

1. Delete the namespace, deployment, service, and ingress in the cluster:

    ```bash
    sh echoserver-terminate.sh
    ```

2. To destroy the resources provisioned by Terraform, run:
   ```bash
   terraform destroy --auto-approve
   ```

## Author

Porames Jariyayanyong | Technical Architect, AWS @ NTT DATA Inc.
