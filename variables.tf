variable "wasabi_access_key" {
  type = string
}

variable "wasabi_secret_key" {
  type = string
  sensitive = true
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
