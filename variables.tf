## Variables - Default values in variables.tfvars
variable "aws_region" {
  description = "provides details about a specific AWS region"
}
variable "aws_az" {
  description = "AZ to start the instance in"
}
variable "aws_ami" {
  description = "AMI to use for the instance"
  type        = map(string)
}
variable "aws_access_key" {
  description = "AWS access key"
}
variable "aws_secret_key" {
  description = "AWS secret key"
}
variable "aws_ssh_public_key" {
  description = "The public key material"
}
variable "aws_ssh_private_key" {
  description = "The private key material"
}
variable "aws_instance_user_data" {
  description = "User data to provide when launching the instance"
}
variable "aws_instance_size" {
  description = "The instance type to use for the instance"
}
variable "aws_vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
}
variable "aws_net_cidr" {
  description = "The IPv4 CIDR block for the subnet"
}
variable "aws_bastion_private_ip" {
  description = "The private IP address assigned to the Instance"
}
