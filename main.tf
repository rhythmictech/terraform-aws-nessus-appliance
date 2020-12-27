locals {
  ami                  = var.use_preauth ? data.aws_ami.preauth_latest.image_id : data.aws_ami.byol_latest.image_id
  create_elb           = ! var.use_preauth
  create_route53_entry = ! var.use_preauth && var.route53_zone_id != null
  keypair_name         = var.create_keypair ? module.ssh_key.ssh_pubkey : var.keypair

  preauth_userdata = templatefile("${path.module}/userdata.tpl",
    {
      key          = var.preauth_key
      scanner_name = var.scanner_name
      role         = aws_iam_role.this.name
    }
  )

  security_groups = concat(
    [aws_security_group.this.id],
    var.additional_security_groups
  )
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name_prefix        = "${var.scanner_name}-role-"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "nessus-"
  role        = aws_iam_role.this.name
}

module "ssh_key" {
  count = var.create_keypair ? 1 : 0

  source  = "rhythmictech/secure-ssh-key/aws"
  version = "~> 2.0.1"

  name = var.scanner_name
  tags = var.tags
}

data "aws_ami" "byol_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["8fn69npzmbzcs4blc4583jd0y"]
  }
}

data "aws_ami" "preauth_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["4m4uvwtrl5t872c56wb131ttw"]
  }
}

resource "aws_instance" "this" {
  ami                    = local.ami
  ebs_optimized          = true
  iam_instance_profile   = aws_iam_instance_profile.this.name
  instance_type          = var.instance_type
  key_name               = local.keypair_name
  subnet_id              = var.instance_subnet_id
  user_data              = var.use_preauth ? local.preauth_userdata : null
  vpc_security_group_ids = local.security_groups

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }

  tags = merge(var.tags, {
    "Name" = var.scanner_name
  })

  volume_tags = merge(var.tags, var.additional_volume_tags, {
    "Name" = var.scanner_name
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_route53_record" "this" {
  count = local.create_route53_entry ? 1 : 0

  name    = var.nessus_dns_entry
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
    evaluate_target_health = true
  }
}
