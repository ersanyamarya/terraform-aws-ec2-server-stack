variable "instances" {
  type = list(object({
    ami                   = string
    instance_type         = string
    startup_script        = string
    key_name              = string
    name                  = string
    volume_size           = string
    delete_on_termination = bool
    ports = object({
      ingress = list(number)
      egress  = list(number)
    })
    hasElasticIp = bool
    aws_route53_record = list(object({
      zone_id = string
      name    = string
      type    = string
      ttl     = string
    }))
  }))
}

variable "global_tags" {
  type = map(string)
}

