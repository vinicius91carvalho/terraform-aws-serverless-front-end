locals {
  bucket_name = "${var.environment}-${var.project_name}.${var.domain}-${var.region}-${var.account_id}-s3-bucket"
}

/*
  Cria o bucket que conterá os logs dos acessos ao site hospedado no S3
*/
resource "aws_s3_bucket" "log" {
  bucket        = "${local.bucket_name}-logs"
  acl           = "log-delivery-write"
  force_destroy = true
}

/*
  Cria o bucket no S3 que hospedará a aplicação
*/
resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name
  acl    = "public-read"
  policy = templatefile("${path.module}/templates/iam-policy-s3-public.tpl", {
    bucket_name = local.bucket_name
  })

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  logging {
    target_bucket = aws_s3_bucket.log.bucket
    target_prefix = var.domain
  }
}

# // Descomentar caso queira gerar a versão de produção do site e enviar ao S3 local 
# /*
#   Instala as dependências e gera a versão de produção da aplicação
# */
# resource "null_resource" "build" {

#   triggers {
#     from_pipeline = "${var.from_pipeline}${md5(file("${var.website_path_from_app}/build/index.html"))}"
#   }

#   provisioner "local-exec" {
#     command = "cd ${var.website_path_from_app} && npm i && npm run build"
#   }

#   depends_on = [aws_s3_bucket.website]
# }

# /*
#   Copia a aplicação para o bucket
# */
# resource "null_resource" "deploy" {

#   from_pipeline = "${var.from_pipeline}${md5(file("${var.website_path_from_app}/build/index.html"))}"

#   provisioner "local-exec" {
#     command = "aws s3 sync ${var.website_path_from_app}/build/ s3://${local.bucket_name}"
#   }

#   depends_on = [null_resource.build]
# }
