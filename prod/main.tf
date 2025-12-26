terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
      configuration_aliases = [aws, aws.usw2]
    }
  }
}

module "mastodon-s3" {
  source = "../modules/s3-bucket"

  project = "mastodon"
  enable_cname = false
}

module "db-backups-s3" {
  source = "../modules/s3-bucket"

  project = "db-backups"
  enable_cname = false
}
