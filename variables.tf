variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_profile" {
  type    = string
  default = "mlops"
}

# VPC
variable "vpc_name" {
  type    = string
  default = "mlops-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-1a","eu-west-1b","eu-west-1c"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

# EKS
variable "cluster_name" {
  type    = string
  default = "mlops-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "cpu_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "cpu_node_desired" {
  type    = number
  default = 2
}

variable "cpu_node_min" {
  type    = number
  default = 1
}

variable "cpu_node_max" {
  type    = number
  default = 3
}

variable "enable_gpu_node_group" {
  type    = bool
  default = false
}

variable "gpu_instance_types" {
  type    = list(string)
  default = ["g4dn.xlarge"]
}

variable "gpu_node_desired" {
  type    = number
  default = 0
}

variable "gpu_node_min" {
  type    = number
  default = 0
}

variable "gpu_node_max" {
  type    = number
  default = 1
}
