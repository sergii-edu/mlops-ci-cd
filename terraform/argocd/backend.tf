terraform {
  backend "s3" {
    # ⚠️ UPDATE to your bucket/region/profile
    bucket  = "mlops-terraform-goit"
    key     = "argocd/terraform.tfstate"
    region  = "us-east-1"
    profile = "goit-terraform"
  }
}
