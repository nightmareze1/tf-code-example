

locals {
  vault_user_data = templatefile(
    var.user_supplied_userdata_path != null ? var.user_supplied_userdata_path : "${path.module}/templates/install_vault.sh.tpl",
    {
      region                = var.aws_region
      name                  = var.resource_name_prefix
      vault_version         = var.vault_version
      kms_key_arn           = var.kms_key_arn
      secrets_manager_arn   = var.secrets_manager_arn
      leader_tls_servername = var.leader_tls_servername
      DATADOG_API_KEY       = var.DATADOG_API_KEY
      env                   = var.env
      vault_version         = var.vault_version
    }
  )
  monitoring_user_data = templatefile(
    "${path.module}/templates/install_monitoring.tpl",
    {
      region          = var.aws_region
      name            = var.resource_name_prefix
      DATADOG_API_KEY = var.DATADOG_API_KEY
      env             = var.env
    }
  )
}
