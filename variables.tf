variable "wasabi_access_key" {
  type = string
  description = "This has to be account root user. If you hit 403, try to rotate key first."
}

variable "wasabi_secret_key" {
  type = string
  sensitive = true
  description = "This has to be account root user. If you hit 403, try to rotate key first."
}

variable "cloudflare_api_token" {
  type = string
  sensitive = true
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}
