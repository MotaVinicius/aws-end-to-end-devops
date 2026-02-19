terraform {
  backend "s3" {
    bucket = "<Meu_Bucket>"
    key    = "<Path>/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
    use_lockfile = true
  }
}
