output "ecs_security_group_id" {
  value = aws_security_group.my_sg.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.my_sg.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.my_sg.name
}