###############
# KMS Secrets #
###############
resource "aws_kms_key" "eks_secrets" {
  count                   = var.set_kms_secrets_key == true ? 1 : 0
  provider                = aws.current
  description             = "${var.cluster_name} EKS Cluster secret encryption key"
  deletion_window_in_days = var.kms_secrets_key_deletetion_window
  enable_key_rotation     = var.kms_secrets_key_rotation
}

resource "aws_kms_alias" "eks_secrets" {
  count         = var.set_kms_secrets_key == true ? 1 : 0
  provider      = aws.current
  name          = "alias/eks_${var.cluster_name}_secrets"
  target_key_id = aws_kms_key.eks_secrets[0].key_id
}

###########
# KMS EBS #
###########
# This policy is required for the KMS key used for EKS root volumes, so the cluster is allowed to enc/dec/attach encrypted EBS volumes

# This resource is needed if you haven't created an autoscaling group yet in the account
resource "aws_iam_service_linked_role" "autoscaling" {
  count            = var.kms_ebs_autoscaling_linked_role == true ? 1 : 0
  provider         = aws.current
  aws_service_name = "autoscaling.amazonaws.com"
}
data "aws_iam_policy_document" "eks_ebs" {
  count    = var.set_kms_ebs_key == true ? 1 : 0
  provider = aws.current
  # Copy of default KMS policy that lets you manage it
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Required for EKS
  statement {
    sid = "Allow service-linked role use of the CMK"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-karpenter-role", # karpenter encrypted PVCs
        var.kms_ebs_iam_role_arn
      ]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-karpenter-role", # karpenter encrypted PVCs
        var.kms_ebs_iam_role_arn
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "eks_ebs" {
  count                   = var.set_kms_secrets_key == true ? 1 : 0
  provider                = aws.current
  description             = "${var.cluster_name} EKS Cluster EBS encryption key"
  deletion_window_in_days = var.kms_ebs_key_deletetion_window
  enable_key_rotation     = var.kms_ebs_key_rotation
  policy                  = data.aws_iam_policy_document.eks_ebs[0].json

  depends_on = [
    aws_iam_service_linked_role.autoscaling
  ]
}

resource "aws_kms_alias" "eks_ebs" {
  count         = var.set_kms_ebs_key == true ? 1 : 0
  provider      = aws.current
  name          = "alias/eks_${var.cluster_name}_ebs"
  target_key_id = aws_kms_key.eks_ebs[0].key_id
}

####################
# EC2 Service Role #
####################
data "aws_iam_policy_document" "assume_ec2" {
  count    = var.set_ec2_role == true ? 1 : 0
  provider = aws.current
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    dynamic "condition" {
      for_each = local.set_ec2_role_by_region
      content {
        test     = "StringEquals"
        variable = "aws:RequestedRegion"
        values   = [data.aws_region.current.id]
      }
    }
  }
}

resource "aws_iam_role" "eks_node" {
  count              = var.set_ec2_role == true ? 1 : 0
  provider           = aws.current
  name               = "${var.project}-${local.environment}-EKS-${var.ec2_role_by_region == true ? "${local.region_name}-" : ""}eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2[0].json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

##########################
# EKS Control Plane Role #
##########################
data "aws_iam_policy_document" "assume_control_plane" {
  count    = var.set_ec2_role == true ? 1 : 0
  provider = aws.current
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    dynamic "condition" {
      for_each = local.set_ec2_role_by_region
      content {
        test     = "StringEquals"
        variable = "aws:RequestedRegion"
        values   = [data.aws_region.current.id]
      }
    }
  }
}

resource "aws_iam_role" "eks_control_plane" {
  count              = var.set_ec2_role == true ? 1 : 0
  provider           = aws.current
  name               = "${var.project}-${local.environment}-EKS-${var.ec2_role_by_region == true ? "${local.region_name}-" : ""}eks-ControlPlane-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2[0].json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

######################
# Load Balancer Role #
######################
module "irsa_role_load_balancer" {
  count                                  = var.set_load_balancer_role == true ? 1 : 0
  providers                              = { aws = aws.current }
  source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                                = "5.10.0"
  role_name                              = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-load-balancer-role"
  policy_name_prefix                     = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-"
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = length(var.irsa_namespaces) == 0 ? ["kube-system:load-balancer-controller-sa"] : var.irsa_namespaces
    }
  }
}

# module "irsa_role_external_dns" {
#   count                         = var.set_external_dns_role == true ? 1 : 0
#   providers                     = { aws = aws.current }
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version                       = "5.10.0"
#   role_name                     = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-external-dns-role"
#   policy_name_prefix            = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-"
#   external_dns_hosted_zone_arns = var.dns_arns
#   attach_external_dns_policy    = true
#   oidc_providers = {
#     main = {
#       provider_arn               = var.oidc_provider_arn
#       namespace_service_accounts = length(var.irsa_namespaces) == 0 ? ["kube-system:external-dns-sa"] : var.irsa_namespaces
#     }
#   }
# }

module "irsa_role_karpenter" {
  count                                   = var.set_karpenter_role == true ? 1 : 0
  providers                               = { aws = aws.current }
  source                                  = "../../modules/iam-role-for-service-accounts-eks/"
  role_name                               = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-karpenter-role"
  policy_name_prefix                      = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-"
  attach_karpenter_controller_policy      = true
  karpenter_controller_cluster_id         = var.cluster_id
  karpenter_controller_node_iam_role_arns = local.node_role_arns
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = length(var.irsa_namespaces) == 0 ? ["karpenter:karpenter"] : var.irsa_namespaces
    }
  }
}

module "irsa_role_ebs_csi" {
  count                 = var.set_ebs_csi_role == true ? 1 : 0
  providers             = { aws = aws.current }
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "5.10.0"
  role_name             = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-ebs-csi-role"
  policy_name_prefix    = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.cluster_name}-"
  ebs_csi_kms_cmk_ids   = [aws_kms_key.eks_ebs[0].arn]
  attach_ebs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = length(var.irsa_namespaces) == 0 ? ["kube-system:ebs-csi-sa"] : var.irsa_namespaces
    }
  }
}
