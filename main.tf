terraform {
  required_providers {
    wasabi = {
      source = "k-t-corp/wasabi"
      version = "4.1.2"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.19.2"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "remote" {
    organization = "sekaisoft"
    workspaces {
      name = "terraform"
    }
  }
}

module "global" {
  source = "./global"
}

provider "wasabi" {
  region = module.global.default_s3_region
  access_key = var.wasabi_access_key
  secret_key = var.wasabi_secret_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

provider "aws" {
  alias = "usw2"
  region = "us-west-2"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

module "prod" {
  source = "./prod"
  providers = {
    aws = aws
    aws.usw2 = aws.usw2
  }
}
