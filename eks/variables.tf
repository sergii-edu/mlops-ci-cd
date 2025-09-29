variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }

variable "cluster_name"    { type = string }
variable "cluster_version" { type = string }

variable "cpu_instance_types" { type = list(string) }
variable "cpu_node_desired"   { type = number }
variable "cpu_node_min"       { type = number }
variable "cpu_node_max"       { type = number }

variable "enable_gpu_node_group" { type = bool }
variable "gpu_instance_types"    { type = list(string) }
variable "gpu_node_desired"      { type = number }
variable "gpu_node_min"          { type = number }
variable "gpu_node_max"          { type = number }
