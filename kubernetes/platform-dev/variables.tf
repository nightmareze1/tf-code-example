variable "aws_profile" {
  description = "AWS Credentials Profile where this terraform will be executed"
  type        = string
}

variable "aws_region" {
  description = "Region where all this terraform will be generated"
  type        = string
}

variable "aws_azs" {
  description = "List of availability Zones that we want to use, specfied by its letter"
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "aws_tags" {
  description = "map of Key / Value pairs to be included in all AWS elements. Those will be merged with local.std_tags"
  type        = map(string)
  default     = {}
}

variable "project" {
  type        = string
}

variable "product" {
  type        = string
}

variable "environment_global" {
  type        = string
}

variable "country" {
  type        = string
}

variable "environment" {
  description = "Environment where we will be executing. This should match with the workspace name and we use uppercases"
  type        = string
  default     = "dev"
}

variable "key_name" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "cluster_subnets" {
  type = list
  default = [""]
}

variable "default_subnets_id" {
    type = list
    default = [""]
}

# variable "istio_system_subnets_id" {
#     type = list
#     default = [""]
# }
# variable "applications_pci_subnets_id" {
#     type = list
#     default = [""]
# }
# variable "monitoring_system_subnets_id" {
#     type = list
#     default = [""]
# }

variable "ingress_port_ssh" {
  type = list
  default = [""]
}
variable "ingress_all_traffic" {
  type = list
  default = [""]
}
variable "ingress_https_traffic" {
  type = list
  default = [""]
}


variable "eks_cluster" {
  description = "Map of clusters to be created"
  type = object({
    name              = string
    ami_id            = string
    eks_version       = optional(string, "1.29")
    monitoring        = optional(bool, true)
    irsa_namespaces   = optional(list(string), ["argocd", "kube-system"])
    disk_size         = optional(number, 50)
    create_namespaces = optional(list(string), ["argocd", "backend"])
    argocd_config     = optional(map(any), {})
    spot = optional(object({
      min_size       = optional(number, 1)
      max_size       = optional(number, 1)
      desired_size   = optional(number, 1)
      instance_types = optional(list(string), ["t2.large","t3.large","m5.large"])
      group          = string
      }), {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t3.xlarge"]
      group = "spot"
    })
    on-demand = optional(object({
      min_size       = optional(number, 1)
      max_size       = optional(number, 1)
      desired_size   = optional(number, 1)
      instance_types = optional(list(string), ["t3a.2xlarge","t3.2xlarge","m5.2xlarge","t2.2xlarge","t3a.xlarge","t3.xlarge","m5.xlarge","t2.xlarge"])
      group          = string
      }), {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t3.xlarge"]
      group = "on-demand"
    })
    od-istio = optional(object({
      min_size       = optional(number, 1)
      max_size       = optional(number, 1)
      desired_size   = optional(number, 1)
      instance_types = optional(list(string), ["t3a.large","t3.large","m5.large"])
      group          = string
      }), {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t3.xlarge"]
      group = "od-istio"
    })
  })
  # default = {}
}
