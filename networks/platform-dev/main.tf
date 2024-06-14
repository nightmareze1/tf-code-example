###### AWS Provider ######
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    profile = "foo-sandbox"
    encrypt = "true"
    region  = "us-west-2"
    bucket = "foo-tf-state"
    key = "tf-foo-sandbox/networks/dev_tf_core.tfstate"
    dynamodb_table = "foo-sandbox-tf-state"
  }
}
