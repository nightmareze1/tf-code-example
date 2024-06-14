locals {
  repo_name    = "dev"
  repo_version = "v1.0.0"
  environment  = var.environment
  region_name  = split("-", data.aws_region.current.id)[1]
  std_tags = merge({
    "project"                  = var.project
    "product"                  = var.product
    "env"                      = var.environment
    "country"                  = var.country
    "env_global"               = var.environment_global
    "role"                     = "eks"
    "terraform"                = "true"
  })

  # EKS
  cluster_name = "${var.project}-${local.environment}-${local.region_name}-${var.eks_cluster.name}-eks"
}
