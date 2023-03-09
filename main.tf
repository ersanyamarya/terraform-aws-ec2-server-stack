# This code creates an instance with a root block device.
# The root block device size is configurable and the volume can be deleted on termination.
# The root block device has a tag that is attached to it.

resource "aws_instance" "instance" {
  count           = length(var.instances)
  ami             = var.instances[count.index].ami
  instance_type   = var.instances[count.index].instance_type
  user_data       = file(var.instances[count.index].startup_script)
  security_groups = [aws_security_group.security_group[count.index].name]
  key_name        = var.instances[count.index].key_name
  tags = merge(
    {
      Name      = var.instances[count.index].name
      Terraform = true
    },
    var.global_tags,
  )

  root_block_device {
    volume_size           = var.instances[count.index].volume_size
    delete_on_termination = var.instances[count.index].delete_on_termination
    tags = merge(
      {
        Name      = "${var.instances[count.index].name}-root-block-device"
        Terraform = true
      },
      var.global_tags,
    )
  }
}

# This code creates an elastic IP for each instance defined in the variable instances and hasElasticIp set to true

resource "aws_eip" "eip" {
  count = length([
    for instance in var.instances :
    instance if instance.hasElasticIp
  ])
  instance = aws_instance.instance[count.index].id
  tags = merge(
    {
      Name      = "${var.instances[count.index].name}-elastic-ip"
      Terraform = true
    },
    var.global_tags,
  )
}


# This code creates a list of route53_records by merging a list of instances.
# Each instance has a list of aws_route53_record. Each aws_route53_record
# is created by passing the instance's public_ip to the aws_route53_record's
# records.

locals {
  route53_records = merge([
    for index, instance in var.instances : {
      for record in instance.aws_route53_record :
      "${instance.name}-${record.name}" => {
        zone_id = record.zone_id
        name    = record.name
        type    = record.type
        ttl     = record.ttl
        records = [aws_instance.instance[index].public_ip]
      }
    }
  ]...)
}


resource "aws_route53_record" "route53_record" {
  for_each = local.route53_records
  name     = each.value.name
  type     = each.value.type
  zone_id  = each.value.zone_id
  ttl      = each.value.ttl
  records  = each.value.records
  depends_on = [
    aws_instance.instance
  ]
}




# Creates security groups for each instance defined in the variable instances
# Each instance has a list of ports defined for ingress and egress
# The security group allows traffic from all IPv4 and IPv6 addresses
# The security group is tagged with the global tags

resource "aws_security_group" "security_group" {
  count       = length(var.instances)
  name        = "${var.instances[count.index].name}-security-group"
  description = "Security group for ${var.instances[count.index].name}"



  dynamic "ingress" {
    for_each = toset(var.instances[count.index].ports.ingress)
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  dynamic "egress" {
    for_each = toset(var.instances[count.index].ports.egress)
    content {
      from_port        = egress.value
      to_port          = egress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  revoke_rules_on_delete = true
  tags = merge(
    {
      Name = "${var.instances[count.index].name}-security-group"
    },
    var.global_tags,
  )
}

