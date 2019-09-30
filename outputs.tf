output "instance_id" {
  value = aws_instance.nessus.id
}

output "private_ip" {
  value = aws_instance.nessus.private_ip
}

output "eip_available" {
  value = var.create_eip
}
output "eip_address" {
  value = var.create_eip ? aws_eip.nessus_eip[0].public_ip : ""
}

output "nessus_dns_address" {
  value = var.create_r53_address ? (var.create_eip ? aws_route53_record.nessus_dns_name_eip[0].fqdn : aws_route53_record.nessus_dns_name_instance[0].fqdn) : ""
}

