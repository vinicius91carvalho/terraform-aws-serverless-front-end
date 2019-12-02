output "name" {
  value = aws_s3_bucket.website.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}

output "bucket_log_domain_name" {
  value = aws_s3_bucket.log.bucket_domain_name
}

output "arn" {
  value = aws_s3_bucket.website.arn
}

output "website_endpoint" {
  value = aws_s3_bucket.website.website_endpoint
}
