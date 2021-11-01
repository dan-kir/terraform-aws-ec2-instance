## Environment Variables - terraform-aws-ec2-instance.auto.tfvars
variable "aws_region" {}
variable "aws_az" {}
variable "aws_ami" { type = map(string) }
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_ssh_public_key" {}
variable "aws_ssh_private_key" {}
variable "aws_instance_size" {}
variable "aws_vpc_cidr" {}
variable "aws_net_cidr" {}
variable "aws_bastion_private_ip" {}


## AWS Provider Configuration
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

## AWS SSH Keypair
resource "aws_key_pair" "bastion_ssh_key" {
  key_name   = "bastion_ssh_key"
  public_key = file(var.aws_ssh_public_key)
}

## Define AWS VPC
resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = false
  tags                 = { Name = "aws_vpc" }
}

## Internet Gateway
resource "aws_internet_gateway" "aws_gateway" {
  vpc_id = aws_vpc.aws_vpc.id
  tags   = { Name = "aws_gateway" }
}

## Bastion Subnet
resource "aws_subnet" "aws_net" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.aws_net_cidr
  availability_zone = var.aws_az
  tags              = { Name = "aws_net" }
}

## Route Table
resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_gateway.id
  }
  tags = { Name = "public_routes" }
}

## Assign route table to aws_net
resource "aws_route_table_association" "aws_net_routes" {
  subnet_id      = aws_subnet.aws_net.id
  route_table_id = aws_route_table.public_routes.id
}

## Bastion Elastic IP
resource "aws_eip" "bastion_eip" {
  vpc      = true
  instance = aws_instance.bastion.id
}

## Bastion Instance
resource "aws_instance" "bastion" {
  tags                        = { Name = "bastion" }
  key_name                    = aws_key_pair.bastion_ssh_key.key_name
  ami                         = var.aws_ami[var.aws_region]
  availability_zone           = var.aws_az
  instance_type               = var.aws_instance_size
  user_data                   = file("scripts/bastion_bootstrap.sh")
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aws_net.id
  private_ip                  = var.aws_bastion_private_ip
  source_dest_check           = true # disable if implementing NAT
  monitoring                  = true
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 32
  }

  ## Drop a private ssh key on bastion
  provisioner "file" {
    source      = var.aws_ssh_private_key
    destination = "/home/admin/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod go-rwx /home/admin/.ssh/id_rsa"
    ]
  }

  ## Bastion connection details
  connection {
    type        = "ssh"
    user        = "admin"
    private_key = file(var.aws_ssh_private_key)
    host        = self.public_ip
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Bastion security group"
  vpc_id      = aws_vpc.aws_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "bastion_eip" {
  value = aws_eip.bastion_eip.public_ip
}
