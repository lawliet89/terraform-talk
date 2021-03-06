# This file defines the AutoScaling group that we will use to run our clients

data "template_file" "client_user_data" {
  template = "${file("${path.module}/files/client.sh")}"

  vars {
    url            = "${var.app_src_url}"
    branch         = "${var.app_branch}"
    server_fqdn    = "${aws_route53_record.domain.fqdn}"
    server_lb_port = "${var.server_lb_port}"
  }
}

resource "aws_autoscaling_group" "client" {
  launch_configuration = "${aws_launch_configuration.client.name}"

  name                = "${var.client_asg_name}"
  vpc_zone_identifier = "${var.subnet_ids}"

  min_size         = "${var.client_size}"
  max_size         = "${var.client_size}"
  desired_capacity = "${var.client_size}"

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.client_asg_name}"
    propagate_at_launch = true
  }

  # Wait for Terraform 0.12 to interpolate tags from var.tags
}

resource "aws_launch_configuration" "client" {
  name_prefix   = "${var.client_asg_name}"
  image_id      = "${data.aws_ami.ubuntu.image_id}"
  instance_type = "${var.instance_type}"

  user_data = "${data.template_file.client_user_data.rendered}"

  associate_public_ip_address = false
  security_groups             = ["${aws_security_group.client.id}"]

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

resource "aws_security_group" "client" {
  name_prefix = "${var.client_asg_name}"
  description = "Security Group for ${var.client_asg_name}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.client_asg_name}"))}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "client_ssh_inbound" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.ssh_cidr}"]

  security_group_id = "${aws_security_group.client.id}"
}

# LB -> Client
resource "aws_security_group_rule" "client_lb_inbound" {
  type                     = "ingress"
  from_port                = "${local.client_port}"
  to_port                  = "${local.client_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${aws_security_group.client.id}"
}

resource "aws_security_group_rule" "client_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.client.id}"
}
