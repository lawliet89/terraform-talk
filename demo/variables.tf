#######################################
# Required Variables
#######################################
variable "vpc_id" {
  description = "VPC ID to launch resources in"
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch instances in."
  type        = "list"
}

variable "route53_zone" {
  description = "Route53 Zone Name to create the DNS record in"
}

variable "domain" {
  description = "Domain"
}

variable "certificate_arn" {
  description = "ARN of the certificate in ACM to use for the domain"
}

#######################################
# Optional Variables
#######################################
variable "aws_region" {
  description = "Region to deploy to"
  default     = "ap-southeast-1"
}

variable "tags" {
  description = "Tags to add to all resources that support tags"

  default {
    Terraform = "true"
  }
}

variable "client_asg_name" {
  description = "Name of the Autoscaling group for clients"
  default     = "commicchat-client"
}

variable "client_size" {
  description = "Number of client instances to launch"
  default     = 3
}

variable "instance_type" {
  description = "Type of instance to launch"
  default     = "t2.micro"
}

variable "server_asg_name" {
  description = "Name of the Autoscaling group for server"
  default     = "commicchat-server"
}

variable "app_src_url" {
  description = "Git URL to checkout the app source code from"
  default     = "https://github.com/gyng/comicchat.git"
}

variable "app_branch" {
  description = "Git branch to checkout the app source code from"
  default     = "master"
}

variable "ssh_key" {
  description = "Name of the SSH key to allow for SSH access"
  default     = ""
}

variable "ssh_cidr" {
  description = "CIDR to allow SSH access from"
  default     = []
}

variable "lb_name" {
  description = "Name of the load balancer to create"
  default     = "comicchat"
}

variable "server_lb_port" {
  description = "Port to expose the Server WS endpoint"
  default     = 8080
}
