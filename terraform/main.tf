/*
  Obtém informações da conta do usuário que executará as operações na Cloud
*/
data "aws_caller_identity" "current" {}

/*
  Obtém informações do certificado SSL emitido
*/
data "aws_acm_certificate" "cert_issued" {
  domain   = var.domain
  statuses = ["ISSUED"]
}

provider "aws" {
  region = var.region
}

/*
  Configura o estado remoto deste projeto. 
  Basicamente cria bucket e a tabela no dynamodb para permitir apenas uma execução por vez da infra
  O estado é guardado no S3 e o Lock é feita na tabela
  Observação: Esses valores não podem ser dinâmicos
*/
terraform {
  backend "s3" {
    bucket         = "project-name-982687753950-us-east-1-remote-state"
    key            = "front-end/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-name-982687753950-us-east-1-remote-state"
  }
}

/*
  Cria o bucket que conterá a aplicação
*/
module "hosting" {
  source = "./hosting"

  environment           = var.environment
  project_name          = var.project_name
  domain                = var.domain
  region                = var.region
  account_id            = data.aws_caller_identity.current.account_id
  website_path_from_app = var.website_path_from_app
}

/*
  Configura o CDN apontando para o bucket S3 e insere o certificado SSL
*/
module "cdn" {
  source                      = "./cdn"
  bucket_regional_domain_name = module.hosting.bucket_regional_domain_name
  bucket_log_domain_name      = module.hosting.bucket_log_domain_name
  certificate_domain_arn      = data.aws_acm_certificate.cert_issued.arn
  bucket_name                 = module.hosting.name
  domain                      = var.domain
  project_name                = var.project_name
  environment                 = var.environment
}
/*
  Configura o subdomínio no DNS apontando para o CDN
*/
module "dns" {
  source                             = "./dns"
  domain                             = var.domain
  sub_domain                         = "${var.environment}-${var.project_name}"
  cdn_s3_distribution_domain_name    = module.cdn.domain_name
  cdn_s3_distribution_hosted_zone_id = module.cdn.hosted_zone_id
  environment                        = var.environment
  project_name                       = var.project_name
}
