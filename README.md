# terraform-aws-nessus-appliance
Creates a Nessus instance using the AWS Marketplace images provided by Tenable. 

When using Nessus as a standalone scanner (BYOL), an ELB is created automatically to give a proper SSL certificate to your scanner. When running as a pre-authorized scanner (connected to Tenable.io), the ELB is not created.

_`preauth_key` must be correctly set when running preauth mode, and the instance must be able to reach the tenable.io service._

[![tflint](https://github.com/rhythmictech/terraform-aws-nessus-appliance/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-nessus-appliance/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-nessus-appliance/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-nessus-appliance/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-nessus-appliance/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-nessus-appliance/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-nessus-appliance/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-nessus-appliance/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-nessus-appliance/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-nessus-appliance/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example

```hcl
module "nessus" {
  source = "../../terraform-aws-nessus-appliance"

  scanner_name = "nessus"
  subnet_id    = "subnet-1234567890"
  vpc_id       = "vpc-1234567890"
}
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 2.65 |
| random | >= 1.2 |
| template | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.65 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance\_subnet\_id | Subnet to create instance in | `string` | n/a | yes |
| vpc\_id | VPC to create resources in | `string` | n/a | yes |
| additional\_security\_groups | Additional security groups to attach to the instance | `list(string)` | `[]` | no |
| additional\_volume\_tags | Additional tags to apply to instance volume | `map(string)` | `{}` | no |
| allow\_instance\_egress | Attach an all/all egress rule to the instance automatically (no egress rules are defined if this is set to `false`, making for a fairly boring vulnerability scanner) | `bool` | `true` | no |
| allowed\_admin\_cidrs | CIDR ranges that are permitted access to SSH | `list(string)` | `[]` | no |
| create\_keypair | Create a keypair for this instance automatically | `bool` | `false` | no |
| elb\_additional\_sg\_tags | Additional tags to apply to the ELB security group. Useful if you use an external process to manage ingress rules. | `map(string)` | `{}` | no |
| elb\_allowed\_cidr\_blocks | List of allowed CIDR blocks. If `[]` is specified, no inbound ingress rules will be created | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| elb\_certificate | ARN of certificate to associate with ELB | `string` | `null` | no |
| elb\_internal | Create as an internal or internet-facing ELB | `bool` | `true` | no |
| elb\_subnets | Subnets to associate ELB to | `list(string)` | `[]` | no |
| instance\_type | Nessus Instance Type | `string` | `"m5.xlarge"` | no |
| keypair | Keypair to associate instance with (if left null and `create_keypair == false`, the instance will not have a keypair associated) | `string` | `null` | no |
| nessus\_dns\_entry | DNS entry to create in selected zone (not used if `route53_zone_id == null`) | `string` | `"nessus"` | no |
| preauth\_key | Must be set when `use_preauth == true` for the scanner to function. | `string` | `""` | no |
| root\_volume\_size | Size of the appliance root volume (needs to be large enough to hold scan results over time) | `number` | `50` | no |
| route53\_zone\_id | Route 53 zone to create Nessus entry in (leave null to skip) | `string` | `null` | no |
| scanner\_name | Name of the nessus scanner (this will be attached to various resource names) | `string` | `"nessus"` | no |
| tags | Tags to add to supported resources | `map(string)` | `{}` | no |
| use\_preauth | Use pre-authorized scanner? This is an unmanaged instance that talks back to Tenable. An ELB and DNS entry will not be created if this is true. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | Instance ID |
| lb\_arn | ARN of the ELB |
| lb\_dns\_name | DNS Name of the ELB |
| lb\_listener\_arn | ARN of the ELB Listener |
| lb\_zone\_id | Route53 Zone ID of the ELB |
| role\_arn | IAM Role ARN of the instance |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
