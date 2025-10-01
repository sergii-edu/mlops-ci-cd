# Read previously created EKS cluster from remote state (adjust values in variables.tf)
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = var.eks_state_bucket
    key     = var.eks_state_key
    region  = var.eks_state_region
    profile = var.aws_profile
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}
