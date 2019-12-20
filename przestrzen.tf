# TODO:
# EIP
# DNS

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "buster" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"] # Debian 10
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
  name = "lamamind.com."
}


resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.lamamind.id
  name = "przestrzen-dev.${data.aws_route53_zone.lamamind.name}"
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
