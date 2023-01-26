# terraform-aws-ec2-server-stack
## EC2 Server Stack Terraform Module

This Terraform module creates a list of EC2 instances and sets them up according to your specified configurations. It can be used to set up all the EC2 instances required for a setup or microservices architecture. The module also creates security groups, assigns ports, and sets up Route53 records for each instance.

## Inputs

| Name        | Description                                | Type         | Default | Required |
| ----------- | ------------------------------------------ | ------------ | ------- | -------- |
| instances   | list of instances                          | list(object) | n/a     | yes      |
| global_tags | Global tags to be applied to all resources | map(string)  | n/a     | yes      |



- `instances`: A list of objects that define the configuration for each instance to be created. Each object requires the following fields:
  - `ami`: The ID of the Amazon Machine Image (AMI) to use for the instance.
  - `instance_type`: The type of instance to launch.
  - `startup_script`: The path to the startup script to be executed when the instance launches.
  - `key_name`: The name of the SSH key pair to use for the instance.
  - `name`: The name to be used for the instance and its resources.
  - `volume_size`: The size of the root block device, in GB.
  - `delete_on_termination`: A boolean value indicating whether the root block device should be deleted when the instance is terminated.
  - `ports`: An object that defines the ports to be opened on the security group. It requires the following fields:
    - `ingress`: A list of ports to be opened for incoming traffic.
    - `egress`: A list of ports to be opened for outgoing traffic.
  - `hasElasticIp`: A boolean value indicating whether the instance should be associated with a public IP address.
  - `tags`: A map of tags to be applied to the instance.
  - `aws_route53_record` :  A list of objects that defines the configuration for each Route53 record to be created for the instance. Each object requires the following fields:
    - `zone_id`: The ID of the Route53 zone where the record will be created.
    - `name`: The name of the record.
    - `type`: The type of the record (e.g. "A", "CNAME").
    - `ttl`: The time-to-live (TTL) value for the record, in seconds.
- `global_tags`: A map of tags to be applied to all resources created by the module.
  
  
## Outputs

| Name         | Description                  |
| ------------ | ---------------------------- |
| instance_ids | IDs of the created instances |

- `instance_id`: The ID of the created EC2 instance.
- `instance_public_ip`: The public IP address of the created EC2 instance.

## Usage

```hcl
module "ec2_server_stack" {
  source = "ersanyamarya/ec2_server_stack"
  instances = [
    {
      ami = "ami-0c94855ba95c71c99"
      instance_type = "t2.micro"
      startup_script = "./startup_script.sh"
      key_name = "my_key"
      name = "my_instance"
      volume_size = "8"
      delete_on_termination = true
      ports = {
        ingress = [22, 80]
        egress = [22, 80]
      }
      hasElasticIp = true
      tags = {
        "Environment" = "production"
        "Team" = "myteam"
      }
      aws_route53_record = [
        {
          zone_id = "Z1X1Y1Z1"
          name = "my_instance"
          type = "A"
          ttl = "300"
        }
      ]
    }
  ]
  global_tags = {
    "Project" = "myproject"
  }
}

```