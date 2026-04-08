variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Custom AMI ID from Packer"
}

variable "my_ip" {
  description = "Your IP address for SSH access to bastion"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
}

variable "ubuntu_ami" {
  description = "Ubuntu 22.04 AMI ID"
}

variable "amazon_ami" {
  description = "Amazon Linux 2 AMI ID"
}
