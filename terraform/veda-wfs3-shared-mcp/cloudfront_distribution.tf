resource "aws_cloudfront_distribution" "tfer--E1MYAUHEUHR59N" {
  aliases = ["alex.delta-backend.xyz"]
  comment = "veda-backend-alex"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "stac-browser"
    viewer_protocol_policy = "allow-all"
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"

  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    path_pattern           = "/api/ingest*"
    smooth_streaming       = "false"
    target_origin_id       = "ingest-api"
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id          = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods           = ["GET", "HEAD"]
    compress                 = "true"
    default_ttl              = "0"
    max_ttl                  = "0"
    min_ttl                  = "0"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    path_pattern             = "/api/stac*"
    smooth_streaming         = "false"
    target_origin_id         = "stac-api"
    viewer_protocol_policy   = "allow-all"
  }

  ordered_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id          = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods           = ["GET", "HEAD"]
    compress                 = "true"
    default_ttl              = "0"
    max_ttl                  = "0"
    min_ttl                  = "0"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    path_pattern             = "/api/raster*"
    smooth_streaming         = "false"
    target_origin_id         = "raster-api"
    viewer_protocol_policy   = "allow-all"
  }

  ordered_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id          = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods           = ["GET", "HEAD"]
    compress                 = "true"
    default_ttl              = "0"
    max_ttl                  = "0"
    min_ttl                  = "0"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    path_pattern             = "/api/features*"
    smooth_streaming         = "false"
    target_origin_id         = "features-api"
    viewer_protocol_policy   = "allow-all"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = "veda-dev-stac-browser.s3-website-us-west-2.amazonaws.com"
    origin_id   = "stac-browser"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = "6r8ht9b123.execute-api.us-west-2.amazonaws.com"
    origin_id   = "ingest-api"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = "czkqaklfbb.execute-api.us-west-2.amazonaws.com"
    origin_id   = "raster-api"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = "ll8eozrj0b.execute-api.us-west-2.amazonaws.com"
    origin_id   = "stac-api"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = "${aws_alb.alb_ecs.dns_name}"
    origin_id   = "features-api"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  tags = {
    Client  = "nasa-impact"
    Owner   = "ds"
    Project = "veda-backend"
    Stack   = "alex"
  }

  tags_all = {
    Client  = "nasa-impact"
    Owner   = "ds"
    Project = "veda-backend"
    Stack   = "alex"
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:853558080719:certificate/01fc600d-f6b9-4581-b1a8-ac0a68cff7a1"
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}