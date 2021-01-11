resource "aws_security_group" "this" {
  name_prefix = var.scanner_name
  description = "Security Group for Nessus (${var.scanner_name})"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    "Name" = var.scanner_name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nessus_allow_cidrs" {
  count = local.create_elb ? 1 : 0

  description              = "Allow access to web UI from the ELB"
  from_port                = 8834
  protocol                 = "tcp"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = aws_security_group.elb[0].id
  to_port                  = 8834
  type                     = "ingress"
}

resource "aws_security_group_rule" "admin_access" {
  count = length(var.allowed_admin_cidrs) > 0 ? 1 : 0

  cidr_blocks       = var.allowed_admin_cidrs
  description       = "Allow administrative access"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "egress" {
  count = var.allow_instance_egress ? 1 : 0

  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  description       = "Allow Nessus egress"
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"
}
