# The "main" file defines the providers and some other "main" things

provider "aws" {
  version = "~> 1.33"
  region  = "${var.aws_region}"
}

locals {
  client_port = 8080
  server_port = 8084
}

# Find and filter the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
