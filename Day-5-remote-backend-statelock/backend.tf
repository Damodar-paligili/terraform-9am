terraform {
  backend "s3" {
    bucket = "statebucketdeploy"
    key    = "terraform.tfstate"
    dynamodb_table = "veera"
    encrypt = true
    #use_lockfile = true  #s3 native locking process to prevent concurrent state modifications
    region = "us-east-1"
  }
}
#supports latest version >=1.10
#<1.10 we can use dynmodb for state locking as well, but s3 native locking is more efficient and cost effective
#State lockfile : Terraform acquires a state lock to protect the state from being written by multiple users at the same time. Please resolve the issue above and try again