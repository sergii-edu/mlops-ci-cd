variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "goit-terraform"
}

variable "aws_region" {
  description = "AWS region for AWS provider (must match your EKS)"
  type        = string
  default     = "us-east-1"
}

# Remote state with your EKS outputs
variable "eks_state_bucket" {
  description = "S3 bucket with remote state EKS"
  type        = string
  default     = "mlops-terraform-goit"
}

variable "eks_state_key" {
  description = "S3 key for remote state EKS"
  type        = string
  default     = "eks/terraform.tfstate"
}

variable "eks_state_region" {
  description = "Region of the bucket storing the EKS remote state"
  type        = string
  default     = "us-east-1"
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "infra-tools"
}

variable "argocd_chart_version" {
  description = "Version of Argo CD Helm chart"
  type        = string
  default     = "v7.7.5"
}

# Point to THIS SAME repo (mono-repo pattern)
variable "app_repo_url" {
  description = "Public Git repository URL of this mono-repo (so ArgoCD reads gitops/* from here)"
  type        = string
  default     = "https://github.com/<your-account>/<this-repo>.git"
}

variable "app_repo_branch" {
  description = "Branch to watch for GitOps (recommend lesson-7 for submission)"
  type        = string
  default     = "lesson-7"
}
