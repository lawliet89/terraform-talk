# This file defines the load balancer
resource "aws_lb" "lb" {
  name            = "${var.lb_name}"
  security_groups = ["${aws_security_group.lb.id}"]
  subnets         = ["${var.subnet_ids}"]

  tags = "${var.tags}"
}

resource "aws_security_group" "lb" {
  name        = "${var.lb_name}"
  description = "Security group for Comicchat Load balancer"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.lb_name}"))}"
}

##########################
# Listeners Target Groups
##########################

# HTTP listener to redirect to HTTPS
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.sink.arn}"
    type             = "forward"
  }
}

# Sink Target group that goes to nowhere
resource "aws_lb_target_group" "sink" {
  name                 = "${var.lb_name}-sink"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "30"                  # It doesn't matter

  tags = "${var.tags}"
}

resource "aws_lb_listener_rule" "client" {
  listener_arn = "${aws_lb_listener.https.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.client.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.domain.fqdn}"]
  }
}

resource "aws_lb_target_group" "client" {
  name     = "${var.lb_name}-client"
  port     = "${local.client_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags = "${var.tags}"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "${local.client_port}"
  }
}

resource "aws_autoscaling_attachment" "client" {
  alb_target_group_arn   = "${aws_lb_target_group.client.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.client.id}"
}

resource "aws_lb_listener" "server_wss" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.server_lb_port}"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.sink.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "server" {
  listener_arn = "${aws_lb_listener.server_wss.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.server.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.domain.fqdn}"]
  }
}

resource "aws_lb_target_group" "server" {
  name     = "${var.lb_name}-server"
  port     = "${local.server_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags = "${var.tags}"

  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_autoscaling_attachment" "server" {
  alb_target_group_arn   = "${aws_lb_target_group.server.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.server.id}"
}

##########################
# Security Group Rules for LB
##########################
# _ -> LB
resource "aws_security_group_rule" "lb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb.id}"
}

# _ -> LB
resource "aws_security_group_rule" "lb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb.id}"
}

# _ -> LB
resource "aws_security_group_rule" "lb_wss_ingress" {
  type              = "ingress"
  from_port         = "${var.server_lb_port}"
  to_port           = "${var.server_lb_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb.id}"
}

# LB -> Clients
resource "aws_security_group_rule" "lb_client_egress" {
  type                     = "egress"
  from_port                = "${local.client_port}"
  to_port                  = "${local.client_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.client.id}"
  security_group_id        = "${aws_security_group.lb.id}"
}

# LB -> server
resource "aws_security_group_rule" "lb_server_egress" {
  type                     = "egress"
  from_port                = "${local.server_port}"
  to_port                  = "${local.server_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.server.id}"
  security_group_id        = "${aws_security_group.lb.id}"
}
