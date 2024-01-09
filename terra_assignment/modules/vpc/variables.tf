variable "region" {
  description = "AWS region"
  type        = string
}

variable "allowed_externals" {

}
variable "vpc_cider" {
  description = "cidr for vpc "
  type        = string
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "enter the name of the vpc"
}


variable "enable_nat_gateway" {
  description = "Enable NAT gateway"
  default     = false
}
