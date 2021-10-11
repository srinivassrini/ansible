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

#webserver2
output "Webserver2_id" {
  description = "ID of the Webserver1 EC2 instance"
  value       = aws_instance.webserver2.id
}

output "Webserver2_private_ip" {
  description = "Private IP address of the Webserver2 EC2 instance"
  value       = aws_instance.webserver2.private_ip
}

#ALB
output "alb_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.alb1.dns_name
}

#RDS
output "rds_endpoint" {
  description = "The RDS endpoint"
  value       = aws_db_instance.rds.endpoint
}