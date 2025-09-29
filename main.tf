provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source = "./vpc"

  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  azs                = var.azs
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
}

module "eks" {
  source = "./eks"

  # pass networking from VPC outputs
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # CPU
  cpu_instance_types = var.cpu_instance_types
  cpu_node_desired   = var.cpu_node_desired
  cpu_node_min       = var.cpu_node_min
  cpu_node_max       = var.cpu_node_max

  # GPU
  enable_gpu_node_group = var.enable_gpu_node_group
  gpu_instance_types    = var.gpu_instance_types
  gpu_node_desired      = var.gpu_node_desired
  gpu_node_min          = var.gpu_node_min
  gpu_node_max          = var.gpu_node_max
}
