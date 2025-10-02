provider "aws" {
  profile = "mlops"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "mlops-terraform-states-12345"
    key     = "eks/terraform.tfstate"
    region  = "eu-west-1"
    profile = "mlops"
  }
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }
  }

}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = "mlops-eks-cluster"
  cluster_version = "1.30"

  vpc_id     = "vpc-03f7e11b7fd6b8138"
  subnet_ids = ["subnet-0f5fae54780981e9c", "subnet-011eacdcfad859df4", "subnet-037c9064a7b65302d"]

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t2.micro"] # Free Tier eligible
      desired_size   = 2
      min_size       = 1
      max_size       = 3
    }
  }

}



output "cluster_name" {
  value = module.eks.cluster_name
}
