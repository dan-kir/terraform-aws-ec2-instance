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
  user_data                   = file(var.aws_instance_user_data)
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aws_net.id
  private_ip                  = var.aws_bastion_private_ip
  source_dest_check           = true # disable if implementing NAT
  monitoring                  = true
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = var.aws_instance_disk_size
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
