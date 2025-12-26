resource "aws_s3_bucket" "pill-city" {
  provider = aws.usw2

  bucket = "pill-city"
  acl = "private"
}

resource "aws_iam_user" "pill-city-admin-user" {
  name = "pill-city-admin"
}

resource "aws_iam_access_key" "pill-city-admin-user-secret" {
  user = aws_iam_user.pill-city-admin-user.name
}

resource "aws_iam_user_policy" "pill-city-admin-user-policy" {
  name = "pill-city-admin-user-policy"
  user = aws_iam_user.pill-city-admin-user.name

  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:*",
        ],
        Resource: [
          "arn:aws:s3:::${aws_s3_bucket.pill-city.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.pill-city.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_cloudfront_public_key" "pill-city-cf-public-key" {
  name = "pill-city"
  encoded_key = file("public_key.pem")
}

resource "aws_cloudfront_key_group" "pill-city-cf-key-group" {
  name = "pill-city"
  items = [aws_cloudfront_public_key.pill-city-cf-public-key.id]
}

locals {
  cf_s3_origin_id = "PillCity"
}

resource "aws_cloudfront_origin_access_control" "pill-city-cf-oac" {
  name = "pill-city"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "pill-city-cf-distribution" {
  origin {
    domain_name = aws_s3_bucket.pill-city.bucket_regional_domain_name
    origin_id = local.cf_s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.pill-city-cf-oac.id
  }

  enabled = true
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.cf_s3_origin_id
    trusted_key_groups = [aws_cloudfront_key_group.pill-city-cf-key-group.id]
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
}

resource "aws_s3_bucket_policy" "pill-city" {
  provider = aws.usw2

  bucket = aws_s3_bucket.pill-city.id
  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow"
        Principal: {
          Service: "cloudfront.amazonaws.com"
        }
        Action: [
          "s3:GetObject"
        ]
        Resource: [
          "arn:aws:s3:::${aws_s3_bucket.pill-city.bucket}/*"
        ]
        Condition: {
          StringEquals: {
            "AWS:SourceArn": aws_cloudfront_distribution.pill-city-cf-distribution.arn
          }
        }
      }
    ]
  })
}
