output "kms_secrets_key_arn" {
  description = "ARN of the KMS key generated for EKS secrets"
  value       = try(aws_kms_key.eks_secrets[0].arn, "")
}

output "kms_ebs_key_arn" {
  description = "ARN of the KMS key generated for EKS EBS volumes"
  value       = try(aws_kms_key.eks_ebs[0].arn, "")
}

output "ec2_role_arn" {
  description = "ARN of the KMS key generated for EKS EBS volumes"
  value       = try(aws_iam_role.eks_node[0].arn, "")
}


output "load_balancer_role_name" {
  description = "Load Balancer Role name"
  value       = try(module.irsa_role_load_balancer.iam_role_name, "")
}
output "load_balancer_role_arn" {
  description = "Load Balancer Role ARN"
  value       = try(module.irsa_role_load_balancer.iam_role_arn, "")
}

# output "external_dns_role_name" {
#   description = "External DNS Role name"
#   value       = try(module.irsa_role_external_dns.iam_role_name, "")
# }
# output "external_dns_role_arn" {
#   description = "External DNS Role ARN"
#   value       = try(module.irsa_role_external_dns.iam_role_arn, "")
# }

output "karpenter_role_name" {
  description = "Karpenter Role name"
  value       = try(module.irsa_role_karpenter.iam_role_name, "")
}
output "karpenter_role_arn" {
  description = "Karpenter Role ARN"
  value       = try(module.irsa_role_karpenter.iam_role_arn, "")
}

output "ebs_csi_role_name" {
  description = "EBS CSI Role name"
  value       = try(module.irsa_role_ebs_csi.iam_role_name, "")
}
output "ebs_csi_role_arn" {
  description = "EBS CSI Role ARN"
  value       = try(module.irsa_role_ebs_csi.iam_role_arn, "")
}
