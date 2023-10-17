data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "${var.project_name}-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

# Create KubeMasterRole
data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "kube-master" {
  name               = "KubeMasterRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.account_id}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kube-master_attachment" {
  role       = aws_iam_role.kube-master.id
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

# Create new VPC
# Resource VPC, Subnet, NAT, EIP, Security Group
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = "5.0.0"

  name = "${var.project_name}-vpc"

  cidr = "10.99.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.99.1.0/24", "10.99.2.0/24", "10.99.3.0/24"]
  public_subnets  = ["10.99.4.0/24", "10.99.5.0/24", "10.99.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

# Create Security Group for EKS Cluster
# Resource Security Group
resource "aws_security_group" "eks" {
  name        = "{var.project_name}-vpc"
  description = "Allow All traffic"
  vpc_id      = module.vpc.default_vpc_id

  ingress {
    description      = "World"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "${var.project_name}-security-group",
    "kubernetes.io/cluster/${local.cluster_name}" : "owned"
  })
}

# Create EKS Cluster
# Resource IAM Role, EKS Cluster, EC2
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  # version    = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "EC2"
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
  }

  eks_managed_node_groups = {
    "node-${var.project_name}" = {
      instance_types = [var.node_size]
      min_size       = var.node_number - 1
      max_size       = var.node_number
      desired_size   = var.node_number
      capacity_type  = var.node_type
      # use_custom_launch_template = false
      disk_size = var.disk_size
    }
  }

  # aws-auth configmap
  # create_aws_auth_configmap = false
  # manage_aws_auth_configmap = false

  aws_auth_accounts = ["${data.aws_caller_identity.current.account_id}"]

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.kube-master.arn
      username = aws_iam_role.kube-master.name
      groups   = ["system:masters"]
    }
  ]
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  # cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.profile]
      command     = "aws"
    }
  }
}

module "alb_controller" {
  source                           = "./modules/alb-controller"
  cluster_name                     = module.eks.cluster_name
  cluster_identity_oidc_issuer     = module.eks.oidc_provider
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  aws_region                       = var.aws_region
}
