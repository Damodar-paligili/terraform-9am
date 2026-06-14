module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  

  bucket = "damodhar-test-bucket-2026"
  #enabling versioning for s3 bucket
  versioning = {
    enabled = true
  }
  #object ownership for s3 bucket
  object_ownership = "BucketOwnerPreferred"
  #acl for s3 bucket
  #acl = "private"   
}