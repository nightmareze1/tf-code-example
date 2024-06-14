variable "repo_name" {
  description = ""
  type        = string
  default     = "eks_commodities"
}
variable "project" {
  type        = string
  default     = "apps"
}
variable "environment" {
  description = "Environment where we will be executing. This should match with the workspace name and we use uppercases"
  type        = string
}
variable "module_chain" {
  description = "String used to set the terraform/module tag. Wi will append this module name to each generated resource"
  type        = string
}
variable "tags" {
  description = "Map with tags to be included in each resource generated by the module"
  type        = map(any)
  default     = {}
}
variable "cluster_name" {
  description = "Name of the cluster all resources will be created for. Used in the name of multiple resources"
  type        = string
}
variable "aws_roles_module_version" {
  description = "Version of the AWS Roles module to be used"
  type        = string
  default     = "5.10.0"
}

variable "set_kms_secrets_key" {
  description = "Enable or disable the creation of kms key to cypher Kubernetes secrets"
  type        = bool
  default     = true
}
variable "kms_secrets_key_deletetion_window" {
  description = "Deletion window in days applied to the KMS secrets key"
  type        = number
  default     = 7
}
variable "kms_secrets_key_rotation" {
  description = "Enabe or disable rotation for the kms secrets key"
  type        = bool
  default     = true
}

variable "set_kms_ebs_key" {
  description = "Enable or disable the creation of kms key to cypher Kubernetes EBS volumes"
  type        = bool
  default     = true
}
variable "kms_ebs_key_deletetion_window" {
  description = "Deletion window in days applied to the KMS EBS key"
  type        = number
  default     = 7
}
variable "kms_ebs_key_rotation" {
  description = "Enabe or disable rotation for the kms ebs key"
  type        = bool
  default     = true
}
variable "kms_ebs_iam_role_arn" {
  description = "IAM Role ARN that will be permited to use the EBS KMS key"
  type        = string
  default     = ""
}

variable "karpenter_arn" {
  description = "IAM Role ARN that will be permited to use the EBS KMS key"
  type        = string
  default     = ""
}

variable "kms_ebs_autoscaling_linked_role" {
  description = "Controls if the module need to request the creation of AWSServiceRoleForAutoScaling Role, as it is not created until you request your first autoscaling group in the account"
  type        = bool
  default     = true
}

variable "set_ec2_role" {
  description = "Enable or disable the creation of EC2 Service role"
  type        = bool
  default     = true
}
variable "ec2_role_by_region" {
  description = "Enable or disable region condition in the EC2 Service Role"
  type        = bool
  default     = true
}

# variable "set_argocd_master_role" {
#   description = "Enable or disable de creation of ArgoCD Master Role"
#   type        = bool
#   default     = false
# }

# variable "set_argocd_external_role" {
#   description = "Enable or disable de creation of ArgoCD External Role"
#   type        = bool
#   default     = true
# }

variable "set_load_balancer_role" {
  description = "Enable or disable creation of Load Balancer role and policy"
  type        = bool
  default     = true
}
variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider of the cluster. Used to autenticate IRSA apps"
  type        = string
  default     = ""
}
variable "irsa_namespaces" {
  description = "List of namespaces authorized to autenticate with IRSA"
  type        = list(any)
  default     = []
}

variable "set_external_dns_role" {
  description = "Enable or disable creation of external dns role and policy"
  type        = bool
  default     = true
}
variable "dns_arns" {
  description = "List of ARNs to be used as hosted zones by the external DNS module"
  type        = list(string)
  default     = []
}

variable "set_karpenter_role" {
  description = "Enable or disable creation of karpenter role and policy"
  type        = bool
  default     = true
}
variable "cluster_id" {
  description = "Cluster ID where we want to permit Karpenter"
  type        = string
  default     = ""
}
variable "extra_node_role_arns" {
  description = "List of Extra Node Role ARNs to be assigned by new instances launched by Karpenter"
  type        = list(string)
  default     = []
}

variable "set_ebs_csi_role" {
  description = "Enable or disable creation of EBS CSI driver role and policy"
  type        = bool
  default     = true
}
