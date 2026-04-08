output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "ubuntu_instance_ips" {
  description = "Public IPs of the 3 Ubuntu instances"
  value       = aws_instance.ubuntu[*].public_ip
}

output "amazon_instance_ips" {
  description = "Public IPs of the 3 Amazon Linux instances"
  value       = aws_instance.amazon[*].public_ip
}

output "ansible_controller_ip" {
  description = "Public IP of the Ansible controller"
  value       = aws_instance.ansible_controller.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
