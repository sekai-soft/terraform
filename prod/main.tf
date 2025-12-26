module "mastodon-s3" {
  source = "../modules/s3-bucket"

  project = "mastodon"
  enable_cname = false
  public_read = true
}

module "db-backups-s3" {
  source = "../modules/s3-bucket"

  project = "db-backups"
  enable_cname = false
  public_read = false
}
