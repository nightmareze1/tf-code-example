#############
# AWS Providers
#############
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.current
      ]
    }
  }
}

#############
# Generic Data
#############
data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}