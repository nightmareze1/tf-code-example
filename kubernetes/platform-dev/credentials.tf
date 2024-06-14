provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = local.std_tags
  }
}

terraform {
  backend "s3" {
    profile = "foo-sandbox"
    encrypt = "true"
    region  = "us-west-2"
    bucket = "foo-sandbox-tf-state"
    key = "tf-foo-sandbox/kubernetes/platform_dev.tfstate"
    dynamodb_table = "foo-sandbox-tf-state"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["--profile", var.aws_profile, "eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
