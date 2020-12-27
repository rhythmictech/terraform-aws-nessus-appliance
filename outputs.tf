output "instance_id" {
  description = "Instance ID"
  value       = aws_instance.this.id
}

output "lb_arn" {
  description = "ARN of the ELB"
  value       = try(aws_lb.this[0].arn, null)
}

output "lb_dns_name" {
  description = "DNS Name of the ELB"
  value       = try(aws_lb.this[0].dns_name, null)
}

output "lb_listener_arn" {
  description = "ARN of the ELB Listener"
  value       = try(aws_lb_listener.this[0].arn, null)
}

output "lb_zone_id" {
  description = "Route53 Zone ID of the ELB"
  value       = try(aws_lb.this[0].zone_id, null)
}

output "role_arn" {
  description = "IAM Role ARN of the instance"
  value       = aws_iam_role.this.arn
}
