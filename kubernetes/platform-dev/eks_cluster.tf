module "eks_commodities" {
  source = "./modules/eks_commodities"
  module_chain                    = "main"
  environment                     = var.environment
  project                         = var.project
  cluster_name                    = var.eks_cluster.name
  oidc_provider_arn               = module.eks.oidc_provider_arn
  kms_ebs_iam_role_arn            = module.eks.cluster_iam_role_arn
  cluster_id                      = module.eks.cluster_arn
  karpenter_arn                   = module.eks_commodities.karpenter_role_arn
  kms_ebs_autoscaling_linked_role = false
  providers = {
    aws.current       = aws
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "= 19.4.2"

  cluster_name                               = local.cluster_name
  cluster_version                            = var.eks_cluster.eks_version

  subnet_ids                                 = var.default_subnets_id
  vpc_id                                     = var.vpc_id

  cluster_security_group_id                  = aws_security_group.cluster-sg.id
  node_security_group_id                     = aws_security_group.all_worker_mgmt.id

  cluster_ip_family                          = "ipv4"  
  cluster_endpoint_private_access            = true
  cluster_endpoint_public_access             = true
  cluster_endpoint_public_access_cidrs       = ["0.0.0.0/0"]
  create_cluster_security_group              = false
  create_cluster_primary_security_group_tags = false
  create_node_security_group                 = false
  enable_irsa                                = true
  create_kms_key                             = false
  create_iam_role                            = true
  iam_role_name = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.eks_cluster.name}-cluster-role"
  cluster_encryption_policy_name = "${var.project}-${local.environment}-EKS-${local.region_name}-${var.eks_cluster.name}-encryption-policy"
  iam_role_use_name_prefix                   = false
  cluster_encryption_policy_use_name_prefix  = false
  create_aws_auth_configmap                  = false
  manage_aws_auth_configmap                  = true
  aws_auth_roles = [
      {
        rolearn  = module.eks_commodities.ec2_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = module.eks_commodities.karpenter_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "arn:aws:iam::123123123:role/Devops-foo_297fe89ecd38b808"
        username = "devopsfoo:{{SessionName}}"
        groups   = ["system:masters", "system:nodes"]
      }
  ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::123123123:user/cicd-dev"
      username = "cicd-dev"
      groups   = ["system:masters","system:nodes"]
    }
  ]
  cluster_addons = {
    coredns = {
      addon_version     = "v1.11.1-eksbuild.6"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = "v1.29.1-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version     = "v1.16.3-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    # aws-ebs-csi-driver = {}
  }

  cluster_encryption_config = {
    provider_key_arn = module.eks_commodities.kms_secrets_key_arn
    resources        = ["secrets"]
  }

  eks_managed_node_group_defaults = {
    # ami_type               = "BOTTLEROCKET_x86_64"
    # platform               = "bottlerocket"
    # ami_type               = "AL2_x86_64"
    # ami_id               = "ami-0c5198ca4f440c8cc"
    create_launch_template = true
    create_security_group  = false
    node_group_name_prefix = ""
    use_name_prefix        = false
    create_iam_role        = false
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    iam_role_arn           = module.eks_commodities.ec2_role_arn
    enable_monitoring      = var.eks_cluster.monitoring
    autoscaling_group_tags = local.std_tags
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = var.eks_cluster.disk_size
          volume_type           = "gp3"
          encrypted             = true
          kms_key_id            = module.eks_commodities.kms_ebs_key_arn
          delete_on_termination = true
        }
      }
    }
  }

  eks_managed_node_groups = {

    eks-cluster_on-demand = {
      node_group_name      = "EKS-on-demand"
      ami_id               = var.eks_cluster.ami_id
      min_size             = var.eks_cluster.on-demand["min_size"]
      max_size             = var.eks_cluster.on-demand["max_size"]
      desired_size         = var.eks_cluster.on-demand["desired_size"]
      instance_types       = var.eks_cluster.on-demand["instance_types"]
      name                 = "${var.project}-${local.environment}-${local.region_name}-${var.eks_cluster.name}-eks-on-demand"
      launch_template_name = "${var.project}-${local.environment}-${local.region_name}-${var.eks_cluster.name}-eks-on-demand-lt"
      launch_template_tags = local.std_tags
      enable_bootstrap_user_data = false
      labels= {
        group = var.eks_cluster.on-demand["group"]
      }
      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash

        yum install awscli -y

        set -o xtrace

        cat <<EOF > /etc/sysctl.d/99-kubelet-network.conf
        # Have a larger connection range available
        net.ipv4.ip_local_port_range=1024 65000
        
        # Reuse closed sockets faster
        net.ipv4.tcp_tw_reuse=1
        net.ipv4.tcp_fin_timeout=15
        
        # The maximum number of "backlogged sockets".  Default is 128.
        net.core.somaxconn=4096
        net.core.netdev_max_backlog=4096
        
        # 16MB per socket - which sounds like a lot,
        # but will virtually never consume that much.
        net.core.rmem_max=16777216
        net.core.wmem_max=16777216
        
        # Various network tunables
        net.ipv4.tcp_max_syn_backlog=20480
        net.ipv4.tcp_max_tw_buckets=400000
        net.ipv4.tcp_no_metrics_save=1
        net.ipv4.tcp_rmem=4096 87380 16777216
        net.ipv4.tcp_syn_retries=2
        net.ipv4.tcp_synack_retries=2
        net.ipv4.tcp_wmem=4096 65536 16777216
        #vm.min_free_kbytes=65536
        
        # Connection tracking to prevent dropped connections (usually issue on LBs)
        net.netfilter.nf_conntrack_max=262144
        net.ipv4.netfilter.ip_conntrack_generic_timeout=120
        net.netfilter.nf_conntrack_tcp_timeout_established=86400
        
        # ARP cache settings for a highly loaded docker/containerd
        net.ipv4.neigh.default.gc_thresh1=8096
        net.ipv4.neigh.default.gc_thresh2=12288
        net.ipv4.neigh.default.gc_thresh3=16384
        EOF
        
        cat <<EOF > /etc/sysctl.d/11-no-ipv6.conf
        net.ipv6.conf.all.disable_ipv6 = 1
        net.ipv6.conf.default.disable_ipv6 = 1
        net.ipv6.conf.lo.disable_ipv6 = 1
        EOF
        
        systemctl restart systemd-sysctl.service
        
        /etc/eks/bootstrap.sh ${local.cluster_name} --container-runtime containerd --kubelet-extra-args "--node-labels name=${var.eks_cluster.on-demand["group"]} --cluster-dns=169.254.20.10 --kube-reserved cpu=256m,memory=1Gi,ephemeral-storage=1Gi --system-reserved cpu=256m,memory=384Mi,ephemeral-storage=1Gi --eviction-hard nodefs.available<10%,memory.available<128Mi"
      EOT
    }


    eks-cluster_od-istio = {
      node_group_name      = "eks-od-istio"
      ami_id               = var.eks_cluster.ami_id
      min_size             = var.eks_cluster.od-istio["min_size"]
      max_size             = var.eks_cluster.od-istio["max_size"]
      desired_size         = var.eks_cluster.od-istio["desired_size"]
      instance_types       = var.eks_cluster.od-istio["instance_types"]
      name                 = "${var.project}-${local.environment}-${local.region_name}-${var.eks_cluster.name}-eks-od-istio"
      launch_template_name = "${var.project}-${local.environment}-${local.region_name}-${var.eks_cluster.name}-eks-od-istio-lt"
      launch_template_tags = local.std_tags
      enable_bootstrap_user_data = false
      labels= {
        group = var.eks_cluster.od-istio["group"]
      }
      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash

        yum install awscli -y

        set -o xtrace

        cat <<EOF > /etc/sysctl.d/99-kubelet-network.conf
        # Have a larger connection range available
        net.ipv4.ip_local_port_range=1024 65000
   
        # Reuse closed sockets faster
        net.ipv4.tcp_tw_reuse=1
        net.ipv4.tcp_fin_timeout=15
   
        # The maximum number of "backlogged sockets".  Default is 128.
        net.core.somaxconn=4096
        net.core.netdev_max_backlog=4096
   
        # 16MB per socket - which sounds like a lot,
        # but will virtually never consume that much.
        net.core.rmem_max=16777216
        net.core.wmem_max=16777216
   
        # Various network tunables
        net.ipv4.tcp_max_syn_backlog=20480
        net.ipv4.tcp_max_tw_buckets=400000
        net.ipv4.tcp_no_metrics_save=1
        net.ipv4.tcp_rmem=4096 87380 16777216
        net.ipv4.tcp_syn_retries=2
        net.ipv4.tcp_synack_retries=2
        net.ipv4.tcp_wmem=4096 65536 16777216
        #vm.min_free_kbytes=65536
   
        # Connection tracking to prevent dropped connections (usually issue on LBs)
        net.netfilter.nf_conntrack_max=262144
        net.ipv4.netfilter.ip_conntrack_generic_timeout=120
        net.netfilter.nf_conntrack_tcp_timeout_established=86400
   
        # ARP cache settings for a highly loaded docker swarm
        net.ipv4.neigh.default.gc_thresh1=8096
        net.ipv4.neigh.default.gc_thresh2=12288
        net.ipv4.neigh.default.gc_thresh3=16384
        EOF
   
        cat <<EOF > /etc/sysctl.d/11-no-ipv6.conf
        net.ipv6.conf.all.disable_ipv6 = 1
        net.ipv6.conf.default.disable_ipv6 = 1
        net.ipv6.conf.lo.disable_ipv6 = 1
        EOF
   
        systemctl restart systemd-sysctl.service
   
        /etc/eks/bootstrap.sh ${local.cluster_name} --container-runtime containerd --kubelet-extra-args "--node-labels name=${var.eks_cluster.od-istio["group"]} --cluster-dns=169.254.20.10 --kube-reserved cpu=256m,memory=1Gi,ephemeral-storage=1Gi --system-reserved cpu=256m,memory=384Mi,ephemeral-storage=1Gi --eviction-hard nodefs.available<10%,memory.available<128Mi"
      EOT
    }


  }
}

######## SECURITY GROUPS #########
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id
  tags        = {
    "karpenter.sh/discovery" = "${local.cluster_name}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    description = ""
    protocol    = "-1"
    cidr_blocks = var.ingress_all_traffic
  }

  ingress {
    cidr_blocks      = ["10.60.0.0/16"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = [
    ]
    self             = false
    to_port          = 0
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "cluster-sg" {
  name_prefix = "eks-cluster-sg-${local.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = var.ingress_all_traffic
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = var.ingress_https_traffic
  }
  ingress {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      security_groups = [aws_security_group.all_worker_mgmt.id]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self = true
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
