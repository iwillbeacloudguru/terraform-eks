aws_region      = "ap-southeast-1"
project_name    = "porames-ktbg"
cluster_version = "1.28"

vpc_cidr        = "10.69.0.0/16"
private_subnets = ["10.69.1.0/24", "10.69.2.0/24", "10.69.3.0/24"]
public_subnets  = ["10.69.4.0/24", "10.69.5.0/24", "10.69.6.0/24"]

is_nat_enabled = true
is_single_nat_across_az = true

# Comment this if you don't use named profile in aws configure
profile = "AdministratorAccess-899363120725"

# Uncomment this section
# Estimated EC2 Monthly cost: 12,406.54 USD
# Estimated EC2 10 Days cost: 4,135.51 USD
# Total vCPU and Memory: 296 vCPU 592 GB
# Total Disk: 18.94 TB
# node_size = "c6i.2xlarge"
# node_number = 37
# disk_size   = 512

# Comment this section
node_size   = "t3.medium"
node_number = 2
disk_size   = 32

ami_type  = "AL2_x86_64"
node_type = "ON_DEMAND"
