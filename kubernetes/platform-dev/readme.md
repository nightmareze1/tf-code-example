## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | = 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 4.49.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | = 19.4.2 |
| <a name="module_eks_commodities"></a> [eks\_commodities](#module\_eks\_commodities) | ./modules/eks_commodities | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.all_worker_mgmt](https://registry.terraform.io/providers/hashicorp/aws/4.49.0/docs/resources/security_group) | resource |
| [aws_security_group.cluster-sg](https://registry.terraform.io/providers/hashicorp/aws/4.49.0/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.49.0/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/4.49.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_azs"></a> [aws\_azs](#input\_aws\_azs) | List of availability Zones that we want to use, specfied by its letter | `list(string)` | <pre>[<br>  "a",<br>  "b",<br>  "c"<br>]</pre> | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Credentials Profile where this terraform will be executed | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region where all this terraform will be generated | `string` | n/a | yes |
| <a name="input_aws_tags"></a> [aws\_tags](#input\_aws\_tags) | map of Key / Value pairs to be included in all AWS elements. Those will be merged with local.std\_tags | `map(string)` | `{}` | no |
| <a name="input_cluster_subnets"></a> [cluster\_subnets](#input\_cluster\_subnets) | n/a | `list` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_country"></a> [country](#input\_country) | n/a | `string` | n/a | yes |
| <a name="input_default_subnets_id"></a> [default\_subnets\_id](#input\_default\_subnets\_id) | n/a | `list` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_eks_cluster"></a> [eks\_cluster](#input\_eks\_cluster) | Map of clusters to be created | <pre>object({<br>    name              = string<br>    ami_id            = string<br>    eks_version       = optional(string, "1.25")<br>    monitoring        = optional(bool, true)<br>    irsa_namespaces   = optional(list(string), ["argocd", "kube-system"])<br>    disk_size         = optional(number, 50)<br>    create_namespaces = optional(list(string), ["argocd", "backend"])<br>    argocd_config     = optional(map(any), {})<br>    spot = optional(object({<br>      min_size       = optional(number, 1)<br>      max_size       = optional(number, 1)<br>      desired_size   = optional(number, 1)<br>      instance_types = optional(list(string), ["t2.large","t3.large","m5.large"])<br>      group          = string<br>      }), {<br>      min_size       = 1<br>      max_size       = 1<br>      desired_size   = 1<br>      instance_types = ["t3.xlarge"]<br>      group = "spot"<br>    })<br>    on-demand = optional(object({<br>      min_size       = optional(number, 1)<br>      max_size       = optional(number, 1)<br>      desired_size   = optional(number, 1)<br>      instance_types = optional(list(string), ["t2.large","t3.large","m5.large"])<br>      group          = string<br>      }), {<br>      min_size       = 1<br>      max_size       = 1<br>      desired_size   = 1<br>      instance_types = ["t3.xlarge"]<br>      group = "on-demand"<br>    })<br>    od-istio = optional(object({<br>      min_size       = optional(number, 1)<br>      max_size       = optional(number, 1)<br>      desired_size   = optional(number, 1)<br>      instance_types = optional(list(string), ["t2.large","t3.large","m5.large"])<br>      group          = string<br>      }), {<br>      min_size       = 1<br>      max_size       = 1<br>      desired_size   = 1<br>      instance_types = ["t3.xlarge"]<br>      group = "od-istio"<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where we will be executing. This should match with the workspace name and we use uppercases | `string` | `"dev"` | no |
| <a name="input_environment_global"></a> [environment\_global](#input\_environment\_global) | n/a | `string` | n/a | yes |
| <a name="input_ingress_all_traffic"></a> [ingress\_all\_traffic](#input\_ingress\_all\_traffic) | n/a | `list` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_ingress_https_traffic"></a> [ingress\_https\_traffic](#input\_ingress\_https\_traffic) | n/a | `list` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_ingress_port_ssh"></a> [ingress\_port\_ssh](#input\_ingress\_port\_ssh) | n/a | `list` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | n/a | `string` | `""` | no |
| <a name="input_product"></a> [product](#input\_product) | n/a | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | `""` | no |

## Outputs

No outputs.
