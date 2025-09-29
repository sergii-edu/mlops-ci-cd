module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    cpu-nodes = {
      instance_types = var.cpu_instance_types
      desired_size   = var.cpu_node_desired
      min_size       = var.cpu_node_min
      max_size       = var.cpu_node_max
      labels = { role = "cpu" }
    }
    gpu-nodes = {
      instance_types = var.gpu_instance_types
      desired_size   = var.gpu_node_desired
      min_size       = var.gpu_node_min
      max_size       = var.gpu_node_max
      labels = { role = "gpu" }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
