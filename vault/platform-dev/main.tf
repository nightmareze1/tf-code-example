###### AWS Provider ######
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.62.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}


terraform {
  backend "s3" {
    profile = "foo-sandbox"
    encrypt = "true"
    region  = "us-west-2"
    bucket = "foo-sandbox-tf-state"
    key = "tf-foo-sandbox/vault/platform_dev.tfstate"
    dynamodb_table = "foo-sandbox-tf-state"
  }
}
