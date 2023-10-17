aws_region   = "ap-southeast-1"
project_name = "bgp-development"
cluster_version = "1.28"

# Uncomment this section
# Estimated EC2 Monthly cost: 12,406.54 USD
# Estimated EC2 10 Days cost: 4,135.51 USD
# Total vCPU and Memory: 296 vCPU 592 GB
# Total Disk: 18.94 TB
# node_size = "c6i.2xlarge"
# node_number = 37
# disk_size   = 512

# Comment this section
node_size   = "t3.large"
node_number = 3
disk_size   = 32

ami_type    = "AL2_x86_64"
node_type   = "ON_DEMAND"
