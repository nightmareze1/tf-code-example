# aws profile
aws_region = "us-west-2"
aws_profile = "foo-sandbox"

# tags
environment = "dev"
environment_global = "sandbox"
project = "platform"
product = "foo"
country = "sandbox"

## VPC vars

cidr = "10.60.0.0/16"

enable_nat_gateway     = true
single_nat_gateway     = false
one_nat_gateway_per_az = true
enable_dns_hostnames   = true
enable_vpn_gateway     = false

azs                 = ["us-west-2a", "us-west-2b", "us-west-2c"]
private_subnets     = ["10.60.0.0/20",  "10.60.16.0/20", "10.60.32.0/20"]
public_subnets      = ["10.60.48.0/23", "10.60.50.0/23", "10.60.52.0/23"]
kafka_subnets       = ["10.60.56.0/24", "10.60.57.0/24", "10.60.58.0/24"]
database_subnets    = ["10.60.60.0/24", "10.60.61.0/24", "10.60.62.0/24"]
