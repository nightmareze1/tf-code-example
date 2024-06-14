locals {
  module_version         = "v1.0.4"
  environment            = var.environment == "" ? upper(terraform.workspace) : var.environment
  region_name            = split("-", data.aws_region.current.id)[1]
  set_ec2_role_by_region = var.ec2_role_by_region == true ? ["enabled"] : []
  node_role_arns         = compact(concat([try(aws_iam_role.eks_node[0].arn, "")], var.extra_node_role_arns))
}
