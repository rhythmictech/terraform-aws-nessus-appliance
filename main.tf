

resource "aws_security_group" "nessus" {
  name_prefix = "${var.env}-${var.scanner_name}-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8834
    to_port     = 8834
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_admin_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "${var.env}-${var.scanner_name}"
    )
  )

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "nessus_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "nessus_iam_role" {
  name_prefix        = "${var.scanner_name}-role-"
  assume_role_policy = data.aws_iam_policy_document.nessus_assume_role.json

  tags = merge(
    local.common_tags,
    map(
      "Name", "${var.scanner_name}-role"
    )
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role_policy_attachment" "nessus_ec2_attach" {
  role        = aws_iam_role.nessus_iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "nessus_instance_profile" {
  name_prefix = "nessus-"
  role        = aws_iam_role.nessus_iam_role.name
}


resource "tls_private_key" "nessus-root" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nessus-root" {
  key_name_prefix = "nessus-root-"
  public_key      = tls_private_key.nessus-root.public_key_openssh
}

resource "aws_secretsmanager_secret" "nessus-root-key" {
  name_prefix = "${var.scanner_name}-root-key-"
  description = "ssh keypair for ${var.scanner_name}"

  tags = merge(
    local.common_tags,
    map(
      "Name", "${var.scanner_name}-key"
    )
  )
}

resource "aws_secretsmanager_secret_version" "nessus-root-key-value" {
  secret_id     = aws_secretsmanager_secret.nessus-root-key.id
  secret_string = tls_private_key.nessus-root.private_key_pem
}

data "aws_ami" "nessus_byol_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["8fn69npzmbzcs4blc4583jd0y"]
  }

}

data "aws_ami" "nessus_preauth_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["4m4uvwtrl5t872c56wb131ttw"]
  }

}

resource "aws_instance" "nessus" {
    ami                    = var.use_byol ? data.aws_ami.nessus_byol_latest.image_id : data.aws_ami.nessus_preauth_latest.image_id
    instance_type          = var.instance_type
    ebs_optimized          = true
    key_name               = aws_key_pair.nessus-root.key_name
    vpc_security_group_ids = [aws_security_group.nessus.id]
    subnet_id              = var.subnet_id
    iam_instance_profile   = aws_iam_instance_profile.nessus_instance_profile.name

    root_block_device {
        volume_type = "gp2"
        volume_size = var.root_volume_size
    }

    tags = merge(
        local.common_tags,
        map(
            "Name", "${var.env}-${var.scanner_name}"
        )
    )
}

resource "aws_eip" "nessus_eip" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.nessus.id
  vpc      = true
}

resource "aws_route53_record" "nessus_dns_name_eip" {
  count     = (var.create_eip && var.create_r53_address) ? 1 : 0
  zone_id   = var.r53_zone_id
  name      = var.r53_address_prefix
  type      = "A"
  ttl       = "60"
  records = [aws_eip.nessus_eip[0].public_ip]
}

resource "aws_route53_record" "nessus_dns_name_instance" {
  count     = (!var.create_eip && var.create_r53_address) ? 1 : 0
  zone_id   = var.r53_zone_id
  name      = var.r53_address_prefix
  type      = "A"
  ttl       = "60"
  records = [aws_instance.nessus.private_ip]
}
