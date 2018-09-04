provider "aws" {
  version = "~> 1.33"
  region  = "${var.aws_region}"
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

resource "aws_instance" "instance" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  key_name               = "${var.ssh_key_name}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  tags        = "${merge(var.tags, map("Name", "${var.name}"))}"
  volume_tags = "${merge(var.tags, map("Name", "${var.name}"))}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }
}

resource "aws_security_group" "instance" {
  name   = "${var.name}"
  vpc_id = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.name}"))}"
}

resource "aws_security_group_rule" "ssh_inbound" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.ssh_cidr_blocks}"]

  security_group_id = "${aws_security_group.instance.id}"
}
