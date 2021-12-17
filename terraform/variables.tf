variable "project" {
  default     = "cicdPipeline"
  type        = string
  description = "Name of project this VPC is meant to house"
}

variable "cidr_block" {
  default     = "10.192.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.192.10.0/24", "10.192.11.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.192.20.0/24", "10.192.21.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "public_subnets_name" {
  default     = ["CICD-Public-Subnet-1", "CICD-Public-Subnet-2"]
  type        = list
  description = "List of public subnet name"
}

variable "private_subnets_name" {
  default     = ["CICD-Private-Subnet-1", "CICD-Private-Subnet-2"]
  type        = list
  description = "List of private subnet name"
}

variable "private_route_table_name" {
  default     = ["CICD-PrivateRouteTable-1", "CICD-PrivateRouteTable-2"]
  type        = list
  description = "List of private route table name"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}
