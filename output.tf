#Bastion
output "Bastion_id" {
  description = "ID of the Bastion EC2 instance"
  value       = aws_instance.bastionserver.id
}

output "Bastion_public_ip" {
  description = "Public IP address of the Bastion EC2 instance"
  value       = aws_instance.bastionserver.public_ip
}

output "Bastion_private_ip" {
  description = "Private IP address of the Bastion EC2 instance"
  value       = aws_instance.bastionserver.private_ip
}

#Webserver1
output "Webserver1_id" {
  description = "ID of the Webserver1 EC2 instance"
  value       = aws_instance.webserver1.id
}

output "Webserver1_private_ip" {
  description = "Private IP address of the Webserver1 EC2 instance"
  value       = aws_instance.webserver1.private_ip
}

#Appserver1
output "Appserver1_id" {
  description = "ID of the Appserver1 EC2 instance"
  value       = aws_instance.appserver1.id
}

output "Appserver1_private_ip" {
  description = "Private IP address of the Appserver1 EC2 instance"
  value       = aws_instance.appserver1.private_ip
}

#Webserver2
output "Webserver2_id" {
  description = "ID of the Webserver2 EC2 instance"
  value       = aws_instance.webserver2.id
}

output "Webserver2_private_ip" {
  description = "Private IP address of the Webserver2 EC2 instance"
  value       = aws_instance.webserver2.private_ip
}

#Appserver2
output "Appserver2_id" {
  description = "ID of the Appserver2 EC2 instance"
  value       = aws_instance.appserver2.id
}

output "Appserver2_private_ip" {
  description = "Private IP address of the Appserver1 EC2 instance"
  value       = aws_instance.appserver2.private_ip
}

#ALB
output "alb_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.alb1.dns_name
}

#RDS
output "rds_endpoint" {
  description = "The RDS endpoint"
  value       = aws_db_instance.rds.address
}