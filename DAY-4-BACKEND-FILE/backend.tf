terraform {
  backend "s3" {
    bucket = "mybucket03june2026"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
