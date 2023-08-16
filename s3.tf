provider "aws" {
  region = "eu-north-1"
  #shared_credentials_files = "~/.aws/credentials"

}

resource "aws_s3_bucket" "lmsss_bucket" {
  bucket = "lmsss-application"


  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.lmsss_bucket.id
}

output "website_endpoint" {
  value = aws_s3_bucket.lmsss_bucket.website_endpoint
}
