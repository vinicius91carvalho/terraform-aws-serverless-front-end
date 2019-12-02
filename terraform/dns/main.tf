/*
  Obtém a zona da AWS
*/
data "aws_route53_zone" "zone" {
  name         = "${var.domain}."
  private_zone = false
}

/*
  Insere o ALIAS no DNS apontando para o CloudFront
*/
resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "${var.sub_domain}.${var.domain}"
  type    = "A"

  alias {
    name                   = replace(var.cdn_s3_distribution_domain_name, "/[.]$/", "")
    zone_id                = var.cdn_s3_distribution_hosted_zone_id
    evaluate_target_health = false
  }

}
/*
  Insere o ALIAS no DNS apontando para o CloudFront sem o environment (No caso de produção)
*/
resource "aws_route53_record" "domain_prod" {

  count = var.environment == "prod" ? 1 : 0

  zone_id = data.aws_route53_zone.zone.id
  name    = "${var.project_name}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_route53_record.subdomain.name
    zone_id                = aws_route53_record.subdomain.zone_id
    evaluate_target_health = false
  }

}

