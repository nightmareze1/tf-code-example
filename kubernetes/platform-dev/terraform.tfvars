aws_region       = "us-west-2"
aws_profile      = "foo-sandbox"

project             = "platform"
product             = "foo"
country             = "sandbox"
environment         = "dev"
environment_global  = "sandbox"
key_name            = "sandbox-dev"
vpc_id              = "vpc-123123"

ingress_port_ssh              = ["10.60.0.0/16"]
ingress_all_traffic           = ["10.60.0.0/16"]
ingress_https_traffic         = ["10.60.0.0/16"]

default_subnets_id            = ["subnet-123","subnet-345","subnet-456456"]

eks_cluster = {
  name        = "foo"
  eks_version = "1.29"
  ami_id      = "ami-0c4b53c8bf1e82ec4"
  on-demand = {
    min_size     = 1
    max_size     = 2
    desired_size = 1
    group        = "applications-main"
  }
  od-istio = {
    min_size     = 1
    max_size     = 2
    desired_size = 1
    group        = "istio-system"
  }
}
