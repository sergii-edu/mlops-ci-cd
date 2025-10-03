terraform {
  backend "s3" {
    bucket  = "mlops-terraform-states-12345"
    key     = "argocd/terraform.tfstate"
    region  = "eu-west-1"
    profile = "mlops"
  }
}
