# This file manages Route53 records
data "aws_route53_zone" "client" {
  name = "${var.client_route53_zone}"
}

resource "aws_route53_record" "client" {
  zone_id = "${data.aws_route53_zone.client.zone_id}"

  name = "${var.client_domain}"
  type = "A"

  alias {
    name                   = "${aws_lb.lb.dns_name}"
    zone_id                = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}

data "aws_route53_zone" "server" {
  name = "${var.server_route53_zone}"
}

resource "aws_route53_record" "server" {
  zone_id = "${data.aws_route53_zone.server.zone_id}"

  name = "${var.server_domain}"
  type = "A"

  alias {
    name                   = "${aws_lb.lb.dns_name}"
    zone_id                = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}
