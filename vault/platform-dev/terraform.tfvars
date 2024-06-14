######  GENERAL ######
aws_region = "us-west-2"
aws_profile = "foo-sandbox"


##### VAULT #####
vpc_id = "vpc-123"

vault_version = "1.15.2"
vault_private_subnets = ["subnet-063117fc8894e1024","subnet-010269554e23ca43a","subnet-032dbc2060d7cf853"]

user_supplied_ami_id = "ami-123"
instance_type = "t2.micro"
node_count = "3"
monitoring_node_count = "0"
bastion_node_count = "0"
enable_private_ca = false
allowed_inbound_cidrs_lb = ["10.60.0.0/16","10.120.55.6/32"]
