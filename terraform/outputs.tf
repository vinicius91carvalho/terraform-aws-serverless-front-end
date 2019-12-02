// Nome do bucket criado para hospedar o site
output "s3_hosting_name" {
  value = module.hosting.name
}

output "s3_hosting_website_endpoint" {
  value = module.hosting.website_endpoint
}

output "cdn_domain_name" {
  value = module.cdn.domain_name
}

output "cdn_distribution_id" {
  value = module.cdn.id
}

output "site_url" {
  value = "${var.environment}-${var.project_name}.${var.domain}"
}


