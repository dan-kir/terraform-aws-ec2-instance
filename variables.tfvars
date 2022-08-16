## AWS Region
aws_region = "ap-southeast-2" ## Sydney

## AWS Availability Zone
aws_az = "ap-southeast-2a"

## AWS Public AMD64 Debian 11 AMIs
aws_ami = {
  "ap-southeast-2" = "ami-01c840b88b5c5ccc8" ## Sydney
  "ap-northeast-1" = "ami-0fa72bd3d748a670f" ## Tokyo
}

## AWS Application Credentials (API Keys)
aws_access_key = "{access_key_here}"
aws_secret_key = "{secret_key_here}"

## AWS SSH Keys
aws_ssh_public_key  = "~/.ssh/id_rsa.pub"
aws_ssh_private_key = "~/.ssh/id_rsa"

## AWS Instance User Data script
aws_instance_user_data = "scripts/bastion_bootstrap.sh"

## AWS Instance Size
## https://aws.amazon.com/ec2/instance-types/
aws_instance_size = "t2.medium"

## AWS Instance disk size in GBs
aws_instance_disk_size = 8

## AWS VPC Network Variables
aws_vpc_cidr = "10.0.0.0/16"

## AWS Network Variables
aws_net_cidr = "10.0.1.0/24"

## AWS Instance Private IP Addresses
aws_bastion_private_ip = "10.0.1.10"
