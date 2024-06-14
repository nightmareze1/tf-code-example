module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  name    = "${var.resource_name_prefix}-vault"
  cidr    = var.vpc_cidr
  azs     = var.azs
  # enable_nat_gateway       = true
  # one_nat_gateway_per_az   = true
  # public_subnets           = var.public_subnet_cidrs
  private_subnets          = var.private_subnet_cidrs
  enable_dns_hostnames     = true
  enable_dns_support       = true
  enable_dhcp_options      = true
  dhcp_options_domain_name = var.domain
  dhcp_options_tags        = var.common_tags

  tags = var.common_tags
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "${var.resource_name_prefix}-vpc_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = var.common_tags
}

locals {
  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    }
  }
}

data "aws_vpc_endpoint_service" "this" {
  for_each = local.endpoints

  service      = lookup(each.value, "service", null)
  service_name = lookup(each.value, "service_name", null)

  filter {
    name   = "service-type"
    values = [lookup(each.value, "service_type", "Interface")]
  }
}

resource "aws_vpc_endpoint" "this" {
  for_each = local.endpoints

  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.this[each.key].service_name
  vpc_endpoint_type = lookup(each.value, "service_type", "Interface")
  auto_accept       = lookup(each.value, "auto_accept", null)

  security_group_ids  = lookup(each.value, "service_type", "Interface") == "Interface" ? length(distinct(concat([aws_security_group.vpc_tls.id], lookup(each.value, "security_group_ids", [])))) > 0 ? distinct(concat([aws_security_group.vpc_tls.id], lookup(each.value, "security_group_ids", []))) : null : null
  subnet_ids          = lookup(each.value, "service_type", "Interface") == "Interface" ? distinct(concat(module.vpc.private_subnets, lookup(each.value, "subnet_ids", []))) : null
  route_table_ids     = lookup(each.value, "service_type", "Interface") == "Gateway" ? lookup(each.value, "route_table_ids", null) : null
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "service_type", "Interface") == "Interface" ? lookup(each.value, "private_dns_enabled", null) : null

  tags = var.common_tags

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
