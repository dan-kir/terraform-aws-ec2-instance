terraform-aws-ec2-instance
==============================
[![Actively Maintained](https://img.shields.io/badge/Maintenance%20Level-Actively%20Maintained-green.svg)](https://gist.github.com/cheerfulstoic/d107229326a01ff0f333a1d3476e068d)

Template a VPC, Internet Gateway, Network, Security Groups and Instance with Elastic IP.

The public IP address (Elastic IP) will be outputted at completion

Default configurations are for a T2.Medium bastion (jump box) running Debian 11

Requirements
------------
Requires Terraform 1.0.8 or later.

Terraform Variables
--------------
The following is configurable in `terraform-aws-ec2-instance.auto.tfvars`
* Region and Availability Zone
* AMI IDs
* Application Credentials
* SSH Keys
* Instance Size
* IP Addressing

Graph
-------------
![alt text](terraform-graph.svg "terraform-graph.svg")

License
-------
GPL-3.0 License

Author Information
------------------
This template was created by Dan Kir
