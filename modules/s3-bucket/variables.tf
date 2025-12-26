variable "project" {
  type = string
  description = "Project name, used for naming resources"
}

variable "enable_cdn" {
  type = bool
  description = "Whether to enable CDN (and associated CNAME)"
}

variable "enable_cname" {
  type = bool
  description = "Whether to enable (just) CNAME"
}

variable "public_read" {
  type = bool
  default = true
  description = "Whether to enable public read bucket policy"
}