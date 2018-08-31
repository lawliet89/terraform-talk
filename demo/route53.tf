# This file manages Route53 records
data "aws_route53_zone" "domain" {
  name = "${var.route53_zone}"
}

resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"

  name = "${var.domain}"
  type = "A"

  alias {
    name                   = "${aws_lb.lb.dns_name}"
    zone_id                = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}
