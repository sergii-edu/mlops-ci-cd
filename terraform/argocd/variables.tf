variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "mlops"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "infra-tools"
}

variable "argocd_chart_version" {
  description = "Helm chart version for ArgoCD"
  type        = string
  default     = "5.46.7"
}

variable "app_repo_url" {
  description = "Git repository URL for ArgoCD applications"
  type        = string
  default     = "https://github.com/sergii-edu/mlops-ci-cd.git"
}

variable "app_repo_branch" {
  description = "Git repository branch for ArgoCD applications"
  type        = string
  default     = "lesson-7"
}
