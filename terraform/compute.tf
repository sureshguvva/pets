provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "eks-terraform-state-statging"
    key    = "eks/terraform2.tfstate"
    region = "us-west-2"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = "my-demo1"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }


  vpc_id     = "vpc-0072899470bf72f18"
  subnet_ids = ["subnet-0a6e7183b4dccda71", "subnet-0a5b7efb61e20c248"]

#########################
  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      subnet         = "subnet-0a6e7183b4dccda71"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
    }
  }
}
