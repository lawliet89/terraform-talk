# This file defines the AutoScaling group that we will use to run our servers

data "template_file" "server_user_data" {
  template = "${file("${path.module}/files/server.sh")}"

  vars {
    url    = "${var.app_src_url}"
    branch = "${var.app_branch}"
  }
}

resource "aws_autoscaling_group" "server" {
  launch_configuration = "${aws_launch_configuration.server.name}"

  name                = "${var.server_asg_name}"
  vpc_zone_identifier = "${var.subnet_ids}"

  min_size         = "1"
  max_size         = "1"
  desired_capacity = "1"

  tag {
    key                 = "Name"
    value               = "${var.server_asg_name}"
    propagate_at_launch = true
  }

  # Wait for Terraform 0.12 to interpolate tags from var.tags
}

resource "aws_launch_configuration" "server" {
  name_prefix   = "${var.server_asg_name}"
  image_id      = "${data.aws_ami.ubuntu.image_id}"
  instance_type = "${var.instance_type}"

  user_data = "${data.template_file.server_user_data.rendered}"

  associate_public_ip_address = false
  security_groups             = ["${aws_security_group.server.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = "true"
  }

  # SSH Access
  key_name = "${var.ssh_key}"

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "server" {
  name_prefix = "${var.server_asg_name}"
  description = "Security Group for ${var.server_asg_name}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.server_asg_name}"))}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "server_ssh_inbound" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.ssh_cidr}"]

  security_group_id = "${aws_security_group.server.id}"
}

# LB -> server
resource "aws_security_group_rule" "server_lb_inbound" {
  type                     = "ingress"
  from_port                = "${local.server_port}"
  to_port                  = "${local.server_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${aws_security_group.server.id}"
}

resource "aws_security_group_rule" "server_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.server.id}"
}
