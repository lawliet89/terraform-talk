variable "ssh_key_name" {
  description = "Name of SSH key to use with the instance"
}

variable "subnet_id" {
  description = "ID of subnet to launch in"
}

variable "vpc_id" {
  description = "VPC ID to launch resources in"
}

#######################################
# Optional Variables
#######################################
variable "aws_region" {
  description = "Region to deploy to"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "Type of instance to provision"
  default     = "t2.micro"
}

variable "name" {
  description = "Name of resources to provision"
  default     = "Terraform Demo"
}

variable "tags" {
  description = "Additional tags for resources"

  default = {
    Terraform = "true"
  }
}

variable "ssh_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH access"
  default     = []
}
