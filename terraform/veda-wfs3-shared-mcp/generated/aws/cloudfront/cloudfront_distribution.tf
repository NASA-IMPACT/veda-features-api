resource "aws_cloudfront_distribution" "tfer--E19SG8OJH9PZ0W" {
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "0"

    forwarded_values {
      cookies {
        forward = "all"
      }

      headers      = ["Authorization", "CloudFront-Is-Desktop-Viewer", "CloudFront-Is-Mobile-Viewer", "CloudFront-Is-Tablet-Viewer", "CloudFront-Viewer-Country"]
      query_string = "true"
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = "true"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:amustlp-0kl1dlr:4"
    }

    lambda_function_association {
      event_type   = "origin-response"
      include_body = "false"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:amustlp-0kl1dlr:4"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "amustlp-dybv83e"
    viewer_protocol_policy = "redirect-to-https"
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "86400"

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    path_pattern           = "_next/static/*"
    smooth_streaming       = "false"
    target_origin_id       = "amustlp-dybv83e"
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "86400"

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    path_pattern           = "static/*"
    smooth_streaming       = "false"
    target_origin_id       = "amustlp-dybv83e"
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "0"

    forwarded_values {
      cookies {
        forward = "all"
      }

      headers      = ["Authorization", "Host"]
      query_string = "true"
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = "true"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:amustlp-0kl1dlr:4"
    }

    lambda_function_association {
      event_type   = "origin-response"
      include_body = "false"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:amustlp-0kl1dlr:4"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    path_pattern           = "_next/data/*"
    smooth_streaming       = "false"
    target_origin_id       = "amustlp-dybv83e"
    viewer_protocol_policy = "https-only"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"
    domain_name         = "amustlp-dybv83e.s3.us-east-1.amazonaws.com"
    origin_id           = "amustlp-dybv83e"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E19RD5SRD8O6HB"
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}

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

resource "aws_cloudfront_distribution" "tfer--E1P87SC03QQ2OJ" {
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "veda-dev-stac-browser.s3-website-us-west-2.amazonaws.com"
    viewer_protocol_policy = "https-only"
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
    path_pattern           = "/api/stac/*"
    smooth_streaming       = "false"
    target_origin_id       = "5311cl1w5l.execute-api.us-west-2.amazonaws.com"
    viewer_protocol_policy = "https-only"
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
    origin_id   = "veda-dev-stac-browser.s3-website-us-west-2.amazonaws.com"
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

    domain_name = "5311cl1w5l.execute-api.us-west-2.amazonaws.com"
    origin_id   = "5311cl1w5l.execute-api.us-west-2.amazonaws.com"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_distribution" "tfer--E1T7VRMWT58GVT" {
  aliases = ["dev.delta-backend.com"]
  comment = "veda-backend-uah-dev"

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
    path_pattern             = "/api/raster*"
    smooth_streaming         = "false"
    target_origin_id         = "raster-api"
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

    domain_name = "xnv4kvaonc.execute-api.us-west-2.amazonaws.com"
    origin_id   = "stac-api"
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

    domain_name = "z8ucwjq9la.execute-api.us-west-2.amazonaws.com"
    origin_id   = "raster-api"
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
    Project = "veda-backend-uah"
    Stack   = "dev"
  }

  tags_all = {
    Client  = "nasa-impact"
    Owner   = "ds"
    Project = "veda-backend-uah"
    Stack   = "dev"
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:853558080719:certificate/f31853bf-9741-407c-8bdf-4de0f6fff983"
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "tfer--E38R6RL93G7OLX" {
  aliases = ["inject-links.delta-backend.com"]
  comment = "veda-backend-uah-inject-links"

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
    path_pattern             = "/api/stac*"
    smooth_streaming         = "false"
    target_origin_id         = "stac-api"
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

    domain_name = "p2f5bmzwod.execute-api.us-west-2.amazonaws.com"
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

    domain_name = "zfsytewkxg.execute-api.us-west-2.amazonaws.com"
    origin_id   = "stac-api"
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
    Project = "veda-backend-uah"
    Stack   = "inject-links"
  }

  tags_all = {
    Client  = "nasa-impact"
    Owner   = "ds"
    Project = "veda-backend-uah"
    Stack   = "inject-links"
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:853558080719:certificate/f31853bf-9741-407c-8bdf-4de0f6fff983"
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "tfer--E3DV5Z6DITNR4H" {
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "0"

    forwarded_values {
      cookies {
        forward = "all"
      }

      headers      = ["Authorization", "CloudFront-Is-Desktop-Viewer", "CloudFront-Is-Mobile-Viewer", "CloudFront-Is-Tablet-Viewer", "CloudFront-Viewer-Country"]
      query_string = "true"
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = "true"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:jrxzg5b-o7wkpno:10"
    }

    lambda_function_association {
      event_type   = "origin-response"
      include_body = "false"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:jrxzg5b-o7wkpno:10"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "jrxzg5b-nz7bsv9"
    viewer_protocol_policy = "redirect-to-https"
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "86400"

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    path_pattern           = "_next/static/*"
    smooth_streaming       = "false"
    target_origin_id       = "jrxzg5b-nz7bsv9"
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "0"

    forwarded_values {
      cookies {
        forward = "all"
      }

      headers      = ["Authorization", "Host"]
      query_string = "true"
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = "true"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:jrxzg5b-o7wkpno:10"
    }

    lambda_function_association {
      event_type   = "origin-response"
      include_body = "false"
      lambda_arn   = "arn:aws:lambda:us-east-1:853558080719:function:jrxzg5b-o7wkpno:10"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    path_pattern           = "_next/data/*"
    smooth_streaming       = "false"
    target_origin_id       = "jrxzg5b-nz7bsv9"
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "86400"

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }

    max_ttl                = "31536000"
    min_ttl                = "0"
    path_pattern           = "static/*"
    smooth_streaming       = "false"
    target_origin_id       = "jrxzg5b-nz7bsv9"
    viewer_protocol_policy = "https-only"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"
    domain_name         = "jrxzg5b-nz7bsv9.s3.us-east-1.amazonaws.com"
    origin_id           = "jrxzg5b-nz7bsv9"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E19RD5SRD8O6HB"
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_distribution" "tfer--E3MLWMRM5IEOSL" {
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"
    default_ttl     = "0"

    forwarded_values {
      cookies {
        forward = "all"
      }

      headers      = ["User-Agent"]
      query_string = "true"
    }

    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "amarouane-impact-mwaa-853558080719.s3.us-west-2.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_header {
      name  = "Access-Control-Allow-Origin"
      value = "*"
    }

    custom_header {
      name  = "Referer"
      value = "https://d31g35w351v2qf.cloudfront.net/"
    }

    domain_name = "amarouane-impact-mwaa-853558080719.s3.us-west-2.amazonaws.com"
    origin_id   = "amarouane-impact-mwaa-853558080719.s3.us-west-2.amazonaws.com"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E26EXZJ2AU1N93"
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_distribution" "tfer--EBU2BO7YIDCW1" {
  custom_error_response {
    error_caching_min_ttl = "10"
    error_code            = "403"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = "10"
    error_code            = "404"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.tfer--4135ea2d-6df8-44a3-9df3-4b5a84be39ad.id}"
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "earthdata-dashboard-delt-earthdatadashboarddeltad-1toqhuzokn1lp.s3.us-east-1.amazonaws.com"
    viewer_protocol_policy = "allow-all"
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "earthdata-dashboard-delt-earthdatadashboarddeltad-1toqhuzokn1lp.s3-website-us-east-1.amazonaws.com"
    origin_id   = "earthdata-dashboard-delt-earthdatadashboarddeltad-1toqhuzokn1lp.s3.us-east-1.amazonaws.com"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_distribution" "tfer--EIGP2GHD21T0D" {
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.tfer--658327ea-f89d-4fab-a63d-7e88639e58f6.id}"
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "amarouane-data-browse-test.s3-website-us-west-2.amazonaws.com"
    viewer_protocol_policy = "allow-all"
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_header {
      name  = "Referer"
      value = "YW1hcm91YW5lCg"
    }

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = "amarouane-data-browse-test.s3-website-us-west-2.amazonaws.com"
    origin_id   = "amarouane-data-browse-test.s3-website-us-west-2.amazonaws.com"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }
}
