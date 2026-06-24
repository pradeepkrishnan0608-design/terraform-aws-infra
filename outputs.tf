output "public_instance_ip" {
  description = "Public IP of EC2 instance in public subnet"
  value       = aws_instance.pub_instance.public_ip
}

output "private_instance_ip" {
  description = "Private IP of EC2 instance in private subnet"
  value       = aws_instance.pri_instance.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.myvpc.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.pubsub.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.prisub.id
}

