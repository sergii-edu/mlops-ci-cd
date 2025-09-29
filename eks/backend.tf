# ignored when used as child module
terraform {
  backend "s3" {
    bucket  = "mlops-terraform-states-12345"
    key     = "eks/terraform.tfstate"
    region  = "eu-west-1"
    profile = "mlops"
  }
}
