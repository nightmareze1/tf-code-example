variable "this_subnets_ids" {
  description = "If communication can only go to some specific subnets of this vpc. If empty whole vpc cidr is allowed"
  type        = list(string)
  default     = []
}

variable "this_rts_ids" {
  description = "Allows to explicitly specify route tables for this VPC"
  type        = list(string)
  default     = []
}

variable "from_this_associated" {
  description = "If traffic for associated CIDRs TO peer VPC (from this) should be allowed"
  type        = bool
  default     = false
}

variable "from_this" {
  description = "If traffic TO peer vpc (from this) should be allowed"
  type        = bool
  default     = true
}

variable "destination_cidrs" {
  description = "If traffic TO peer vpc (from this) should be allowed"
  type        = list(string)
  default     = []
}

variable "this_vpc_id" {
  description = "This VPC ID: string"
  type        = string
  default     = ""
}

variable "aws_resource_id" {
  type        = string
}
