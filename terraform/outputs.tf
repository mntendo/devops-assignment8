output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "private_instance_ips" {
  description = "Private IPs of the 6 EC2 instances"
  value       = aws_instance.private[*].private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
