terraform {
  required_providers {
    wasabi = {
      source = "k-t-corp/wasabi"
      version = "4.1.2"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.19.2"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "global" {
  source = "../../global"
}

locals {
  endpoint = "s3.${module.global.default_s3_region}.wasabisys.com"
  bucket = "${var.project}-s3.${module.global.root_domain}"
}

resource "wasabi_bucket" "s3-bucket" {
  bucket = local.bucket
  acl = "private"
  force_destroy = false
}

resource "wasabi_bucket_policy" "s3-bucket-policy" {
  count = var.public_read ? 1 : 0

  bucket = wasabi_bucket.s3-bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Effect: "Allow",
        Principal: {
          "AWS": "*"
        },
        Action: "s3:GetObject",
        Resource: "arn:aws:s3:::${wasabi_bucket.s3-bucket.bucket}/*"
      }
    ]
  })
}

resource "wasabi_user" "s3-rw-user" {
  name = var.project
  path = "/"
}

resource "wasabi_policy" "s3-rw-policy" {
  // e.g. converts "herr-ashi" to "HerrAshiRW"
  name = "${replace(title(replace(var.project, "-", " ")), " ", "")}RW"
  path = "/"
  description = "Read/write the ${var.project} bucket"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Effect: "Allow",
        Action: "s3:*",
        Resource: "arn:aws:s3:::${wasabi_bucket.s3-bucket.bucket}/*"
      },
      {
        Effect: "Allow",
        Action: "s3:*",
        Resource: "arn:aws:s3:::${wasabi_bucket.s3-bucket.bucket}"
      }
    ]
  })
}

resource "wasabi_user_policy_attachment" "s3-rw-policy-attachment" {
  user = wasabi_user.s3-rw-user.name
  policy_arn = wasabi_policy.s3-rw-policy.arn
}

resource "wasabi_access_key" "s3-rw-user-access-key" {
  user = wasabi_user.s3-rw-user.name
}

data "cloudflare_zones" "cloudflare-zone" {
  filter {
    name = module.global.root_domain
  }
}

resource "cloudflare_record" "cname" {
  count = var.enable_cname ? 1 : 0
  zone_id = lookup(data.cloudflare_zones.cloudflare-zone.zones[0], "id")
  type = "CNAME"
  name = "${var.project}-s3"
  value = local.endpoint
  ttl = "1"
  proxied = true
}

data "aws_acm_certificate" "aws-root-domain-cert" {
  domain = "*.${module.global.root_domain}"
  statuses = ["ISSUED"]
}

data "aws_cloudfront_cache_policy" "cloudfront-cdn-cache-policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "cloudfront-cdn" {
  count = var.enable_cdn ? 1 : 0

  origin {
    domain_name = local.endpoint
    origin_id = local.bucket
    origin_path = "/${local.bucket}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy = "http-only"
      origin_read_timeout = 30
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  aliases = [local.bucket]
  // e.g. converts "herr-ashi" to "Herr-Ashi S3'
  comment = "${replace(title(replace(var.project, "-", " ")), " ", "-")} S3"
  is_ipv6_enabled = true
  price_class = "PriceClass_200"

  enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.bucket
    viewer_protocol_policy = "allow-all"

    cache_policy_id = data.aws_cloudfront_cache_policy.cloudfront-cdn-cache-policy.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.aws-root-domain-cert.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method = "sni-only"
  }
}

resource "cloudflare_record" "cdn-cname" {
  count = var.enable_cdn ? 1 : 0
  zone_id = lookup(data.cloudflare_zones.cloudflare-zone.zones[0], "id")
  type = "CNAME"
  name = "${var.project}-s3"
  value = aws_cloudfront_distribution.cloudfront-cdn[0].domain_name
  ttl = "1"
  proxied = false
}
