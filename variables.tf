locals {
  common_tags = {
    env       = var.env
    owner     = var.owner
    namespace = var.namespace
  }
}


variable "scanner_name" {
  default = "nessus"
  type    = string
}

variable "region" {
  type = string
}

variable "namespace" {
  type = string
}

variable "env" {
  type = string
}

variable "owner" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_cidrs" {
  type = list(string)
}

variable "allowed_admin_cidrs" {
  type = list(string)
}

variable "additional_tags" {
  default = {}
  type    = map(string)
}

variable "instance_type" {
  type = string
  default = "m4.xlarge"
}

variable "subnet_id" {
  type = string
}

variable "root_volume_size" {
  type = number
  default = 50
}

variable "use_byol" {
  type = bool
  default = true
}

variable "create_eip" {
  type = bool
  default = true
}

variable "create_r53_address" {
  type= bool
  default = true
}

variable "r53_address_prefix" {
  type = string
  default = "nessus"
}

variable "r53_zone_id" {
  type = string
  default = ""
}

variable "allowed_admin_security_group_id" {
  type = string
  default = ""
}

variable "allowed_security_group_id" {
  type = string
  default = ""
}
