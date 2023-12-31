provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "batchjobskippr"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}