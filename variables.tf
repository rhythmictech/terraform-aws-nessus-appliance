########################################
# General Vars
########################################

variable "scanner_name" {
  default     = "nessus"
  description = "Name of the nessus scanner (this will be attached to various resource names)"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}

variable "preauth_key" {
  default     = ""
  description = "Must be set when `use_preauth == true` for the scanner to function."
  type        = string
}

variable "use_preauth" {
  default     = false
  description = "Use pre-authorized scanner? This is an unmanaged instance that talks back to Tenable. An ELB and DNS entry will not be created if this is true."
  type        = bool
}

########################################
# Instance Vars
########################################

variable "additional_security_groups" {
  default     = []
  description = "Additional security groups to attach to the instance"
  type        = list(string)
}

variable "additional_volume_tags" {
  default     = {}
  description = "Additional tags to apply to instance volume"
  type        = map(string)
}

variable "create_keypair" {
  default     = false
  description = "Create a keypair for this instance automatically"
  type        = bool
}

variable "instance_type" {
  default     = "m5.xlarge"
  description = "Nessus Instance Type"
  type        = string
}

variable "keypair" {
  default     = null
  description = "Keypair to associate instance with (if left null and `create_keypair == false`, the instance will not have a keypair associated)"
  type        = string
}

variable "root_volume_size" {
  default     = 50
  description = "Size of the appliance root volume (needs to be large enough to hold scan results over time)"
  type        = number
}

########################################
# Networking Vars
########################################

variable "allow_instance_egress" {
  default     = true
  description = "Attach an all/all egress rule to the instance automatically (no egress rules are defined if this is set to `false`, making for a fairly boring vulnerability scanner)"
  type        = bool
}

variable "allowed_admin_cidrs" {
  default     = []
  description = "CIDR ranges that are permitted access to SSH"
  type        = list(string)
}

variable "elb_additional_sg_tags" {
  default     = {}
  description = "Additional tags to apply to the ELB security group. Useful if you use an external process to manage ingress rules."
  type        = map(string)
}

variable "elb_allowed_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  description = "List of allowed CIDR blocks. If `[]` is specified, no inbound ingress rules will be created"
  type        = list(string)
}

variable "elb_certificate" {
  default     = null
  description = "ARN of certificate to associate with ELB"
  type        = string
}

variable "elb_internal" {
  default     = true
  description = "Create as an internal or internet-facing ELB"
  type        = bool
}

variable "elb_subnets" {
  default     = []
  description = "Subnets to associate ELB to"
  type        = list(string)
}

variable "instance_subnet_id" {
  description = "Subnet to create instance in"
  type        = string
}

variable "vpc_id" {
  description = "VPC to create resources in"
  type        = string
}

########################################
# DNS Vars
########################################

variable "nessus_dns_entry" {
  default     = "nessus"
  description = "DNS entry to create in selected zone (not used if `route53_zone_id == null`)"
  type        = string
}

variable "route53_zone_id" {
  default     = null
  description = "Route 53 zone to create Nessus entry in (leave null to skip)"
  type        = string
}
