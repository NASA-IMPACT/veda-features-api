provider "aws" {
  region = "us-west-1"
}

terraform {
  required_version = "1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "veda-wfs3-tf-state-bucket"
    key            = "root"
    region         = "us-west-1"
  }
}
