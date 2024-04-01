aws_region      = "ap-southeast-1"
project_name    = "XXX"
cluster_version = "1.28"

vpc_cidr        = "10.69.0.0/16"
private_subnets = ["10.69.1.0/24", "10.69.2.0/24", "10.69.3.0/24"]
public_subnets  = ["10.69.4.0/24", "10.69.5.0/24", "10.69.6.0/24"]

is_nat_enabled = true
is_single_nat_across_az = true

# Comment this if you don't use named profile in aws configure
profile = "AdministratorAccess-XXX"

# Adjust sizing via this section
node_size   = "t3.medium"
node_number = 2
disk_size   = 32

ami_type  = "AL2_x86_64"
node_type = "ON_DEMAND"
