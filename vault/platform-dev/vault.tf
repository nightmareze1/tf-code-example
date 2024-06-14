module "secrets" {
  source                = "./modules/secrets"
  resource_name_prefix  = var.resource_name_prefix
  shared_san            = var.lb_fqdn
  validity_period_hours = var.validity_period_hours
  common_tags           = var.common_tags
  domain                = var.domain
  lb_fqdn               = var.lb_fqdn
  enable_private_ca     = var.enable_private_ca
}


module "iam" {
  source = "./modules/iam"
  aws_region                  = var.aws_region
  kms_key_arn                 = module.kms.kms_key_arn
  permissions_boundary        = var.permissions_boundary
  resource_name_prefix        = var.resource_name_prefix
  secrets_manager_arn         = module.secrets.secrets_manager_arn
  user_supplied_iam_role_name = var.user_supplied_iam_role_name
}

module "kms" {
  source = "./modules/kms"
  common_tags               = var.common_tags
  kms_key_deletion_window   = var.kms_key_deletion_window
  resource_name_prefix      = var.resource_name_prefix
  user_supplied_kms_key_arn = var.user_supplied_kms_key_arn
}

module "loadbalancer" {
  source = "./modules/load_balancer"
  allowed_inbound_cidrs   = var.allowed_inbound_cidrs_lb
  common_tags             = var.common_tags
  lb_certificate_arn      = var.enable_private_ca ? module.cas_certs_route53[0].lb_certificate_arn : module.secrets.lb_certificate_arn
  lb_deregistration_delay = var.lb_deregistration_delay
  lb_health_check_path    = var.lb_health_check_path
  lb_subnets              = var.vault_private_subnets
  lb_type                 = var.lb_type
  resource_name_prefix    = var.resource_name_prefix
  ssl_policy              = var.ssl_policy
  vault_sg_id             = module.vm.vault_sg_id
  vpc_id                  = var.vpc_id
}

module "cas_certs_route53" {
  count             = var.enable_private_ca ? 1 : 0
  source            = "./modules/cas_certs_route53"
  vpc_id            = var.vpc_id
  vault_lb_dns_name = module.loadbalancer.vault_lb_dns_name
  vault_lb_zone_id  = module.loadbalancer.vault_lb_zone_id
  domain            = var.domain
  lb_fqdn           = var.lb_fqdn
  common_tags       = var.common_tags
}

module "route53" {
  count             = var.enable_private_ca ? 0 : 1
  source            = "./modules/route53"
  vpc_id            = var.vpc_id
  domain            = var.domain
  lb_fqdn           = var.lb_fqdn
  vault_lb_dns_name = module.loadbalancer.vault_lb_dns_name
  vault_lb_zone_id  = module.loadbalancer.vault_lb_zone_id
}

module "user_data" {
  source = "./modules/user_data"
  aws_region                  = var.aws_region
  kms_key_arn                 = module.kms.kms_key_arn
  leader_tls_servername       = module.secrets.leader_tls_servername
  resource_name_prefix        = var.resource_name_prefix
  secrets_manager_arn         = module.secrets.secrets_manager_arn
  user_supplied_userdata_path = var.user_supplied_userdata_path
  vault_version               = var.vault_version
  DATADOG_API_KEY             = var.DATADOG_API_KEY
  env                         = var.env
  lb_fqdn                     = var.lb_fqdn
  subordinate_ca_arn          = var.enable_private_ca ? module.cas_certs_route53[0].subordinate_ca_arn : ""
}

locals {
  vault_target_group_arns = concat(
    [module.loadbalancer.vault_target_group_arn],
    var.additional_lb_target_groups,
  )
}

module "vm" {
  source = "./modules/vm"
  allowed_inbound_cidrs     = var.allowed_inbound_cidrs_lb
  allowed_inbound_cidrs_ssh = var.allowed_inbound_cidrs_ssh
  aws_iam_instance_profile  = module.iam.aws_iam_instance_profile
  common_tags               = var.common_tags
  instance_type             = var.instance_type
  lb_type                   = var.lb_type
  node_count                = var.node_count
  resource_name_prefix      = var.resource_name_prefix
  userdata_script           = module.user_data.vault_userdata_base64_encoded
  user_supplied_ami_id      = var.user_supplied_ami_id
  vault_lb_sg_id            = module.loadbalancer.vault_lb_sg_id
  vault_subnets             = var.vault_private_subnets
  vault_target_group_arns   = local.vault_target_group_arns
  vpc_id                    = var.vpc_id
  env                       = var.env
}
