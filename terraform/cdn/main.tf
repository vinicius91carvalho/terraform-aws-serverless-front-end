
/*
  Configura o CDN apontando para o bucket S3 passado como parâmetro e insere o certificado SSL
*/
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.environment}-${var.project_name}.${var.domain}"
}

locals {
  aliases = var.environment == "prod" ? ["${var.environment}-${var.project_name}.${var.domain}", "${var.project_name}.${var.domain}"] : ["${var.environment}-${var.project_name}.${var.domain}"]
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  wait_for_deployment = false
  retain_on_delete    = true

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = var.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = var.bucket_log_domain_name
    prefix          = "cloudfront_logs"
  }

  aliases = local.aliases

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_regional_domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  # 1h
    max_ttl                = 86400 # 1d
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_domain_arn
    ssl_support_method  = "sni-only"
  }

}
