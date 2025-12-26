# s3-bucket
Creates an S3 bucket and associated resources on Wasabi, Cloudflare and/or CloudFront

## Resources created
* The bucket
* A bucket policy to allow public read
* An IAM user for read/write
* An IAM policy for read/write
* An IAM policy attachment to link the read/write user and policy
* An access key for the read/write user
* Easier exposure to outside world, either
    * A CDN + a DNS CNAME for caching on CloudFront
    * Or just a DNS CNAME for non caching on Cloudflare

## Data sources required
* AWS ACM certificate for the root domain if caching exposure
* Cloudflare zone for the root domain if non caching exposure
