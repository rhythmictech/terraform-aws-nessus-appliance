resource "aws_security_group" "elb" {
  count = local.create_elb ? 1 : 0

  name_prefix = "${var.scanner_name}-elb"
  description = "Security Group for Nessus ELB"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    var.elb_additional_sg_tags,
    { "Name" : "${var.scanner_name}-elb" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "elb_egress" {
  count = local.create_elb ? 1 : 0

  description              = "Allow traffic from the ELB to the instances"
  from_port                = 8834
  protocol                 = "tcp"
  security_group_id        = aws_security_group.elb[0].id
  source_security_group_id = aws_security_group.this.id
  to_port                  = 8834
  type                     = "egress"
}

resource "aws_security_group_rule" "elb_ingress" {
  count = length(var.elb_allowed_cidr_blocks) > 0 && local.create_elb ? 1 : 0

  cidr_blocks       = var.elb_allowed_cidr_blocks #tfsec:ignore:AWS006
  description       = "Allow traffic from the allowed ranges"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.elb[0].id
  to_port           = 443
  type              = "ingress"
}

resource "aws_lb" "this" {
  count = local.create_elb ? 1 : 0

  name_prefix                      = substr(var.scanner_name, 0, 6)
  enable_cross_zone_load_balancing = "true"
  internal                         = var.elb_internal
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.elb[0].id]
  subnets                          = var.elb_subnets
  tags                             = var.tags
}

resource "aws_lb_listener" "this" {
  count = local.create_elb ? 1 : 0

  certificate_arn   = var.elb_certificate
  load_balancer_arn = aws_lb.this[0].id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = aws_lb_target_group.this[0].id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "this" {
  count = local.create_elb ? 1 : 0

  name_prefix = substr(var.scanner_name, 0, 6)
  port        = 8834
  protocol    = "HTTPS"
  tags        = var.tags
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold = 2
    interval          = 15
    matcher           = "200-299,302"
    protocol          = "HTTPS"
    port              = 8834
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = local.create_elb ? 1 : 0

  target_group_arn = aws_lb_target_group.this[0].arn
  target_id        = aws_instance.this.id
  port             = 8834
}
