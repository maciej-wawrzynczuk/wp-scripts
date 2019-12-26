provider "aws" {
  region = "eu-central-1"
}

variable "fqdn" {}
variable "os" {
  default = "buster"
}

locals {
  fqdn_elements = split(".", var.fqdn)
  fqdn_size = length(local.fqdn_elements)
  domain_elements = slice(local.fqdn_elements, 1, local.fqdn_size)
  domain = join(".", local.domain_elements)
  hostname = element(local.fqdn_elements, 0)

  ami_data = {
    "buster" = {
      "owner" = "136693071363"
      "admin_user" = "admin"
      "search_string" = "debian-10*"
    }
  }
}

output "debug_1" {
  value = local.ami_data
}

data "aws_ami" "buster" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_data[var.os]["search_string"]]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.ami_data[var.os]["owner"]]
}

module "key" {
  source = "git::git@github.com:maciej-wawrzynczuk/terraform-lib.git//ssh-key?ref=v1"
  #source = "../terraform-lib/ssh-key"
  project = "Przestrzen"
}

resource "aws_eip" "my_ip" {
  instance = aws_instance.host.id
  vpc = true
}


resource "aws_instance" "host" {
  ami           = data.aws_ami.buster.id
  instance_type = "t2.micro"
  key_name = module.key.name
  vpc_security_group_ids = [ aws_security_group.sg.id ]
}


data "aws_route53_zone" "lamamind" {
  name = local.domain
}


resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.lamamind.id
  name = "${local.hostname}.${data.aws_route53_zone.lamamind.name}"
  type = "A"
  ttl = "300"
  records = [ aws_eip.my_ip.public_ip ]
}


resource "aws_security_group" "sg" {
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 80    # HTTP - remove once https will work
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "local_file" "ansible_inventory" {
  content = "${var.fqdn} ansible_user=${local.ami_data[var.os]["admin_user"]}"
  filename = "hosts"
  file_permission = "0440"
}
