#data "aws_route53_zone" "zone" {
#  provider = aws.west2
#  name     = var.dns_zone_name
#}
#
#resource "aws_acm_certificate" "cert" {
#  provider = aws.west2
#  domain_name               = "*.${data.aws_route53_zone.zone.name}"
#  validation_method         = "DNS"
#  tags                      = var.tags
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
#resource "aws_route53_record" "subdomain_record" {
#  provider = aws.west2
#  name     = "${var.dns_subdomain}.${data.aws_route53_zone.zone.name}"
#  zone_id  = data.aws_route53_zone.zone.id
#  type     = "A"
#
#  alias {
#    name                   = aws_alb.alb_ecs.dns_name
#    zone_id                = aws_alb.alb_ecs.zone_id
#    evaluate_target_health = true
#  }
#}
#
#resource "aws_lb_listener_certificate" "cert" {
#  provider = aws.west2
#  listener_arn    = aws_alb_listener.alb_listener_ecs.arn
#  certificate_arn = aws_acm_certificate.cert.arn
#}