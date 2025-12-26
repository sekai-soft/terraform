output "endpoint" {
  value = local.endpoint
}

output "endpoint_url" {
  value = "https://${local.endpoint}/"
}

output "region" {
  value = module.global.default_s3_region
}

output "bucket" {
  value = local.bucket
}

output "rw_user_access_key" {
  value = wasabi_access_key.s3-rw-user-access-key.id
}

output "rw_user_secret_key" {
  value = wasabi_access_key.s3-rw-user-access-key.secret
  sensitive = true
}

output "cdn_url" {
  value = "https://${var.project}-s3.${module.global.root_domain}"
}

output "cdn_cname" {
  value = "${var.project}-s3.${module.global.root_domain}"
}
