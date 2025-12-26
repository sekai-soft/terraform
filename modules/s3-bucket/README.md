# s3-bucket
Creates an S3 bucket and associated resources on Wasabi and/or Cloudflare

## Resources created
* The bucket
* A bucket policy to allow public read
* An IAM user for read/write
* An IAM policy for read/write
* An IAM policy attachment to link the read/write user and policy
* An access key for the read/write user
* Easier exposure to outside world via a DNS CNAME on Cloudflare

## Data sources required
* Cloudflare zone for the root domain if non caching exposure
