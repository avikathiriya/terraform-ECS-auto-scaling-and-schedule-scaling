output "cluster_id" {
  value = aws_ecs_cluster.my_ecs_cluster.id
}

output "cluster_name" {
  value = aws_ecs_cluster.my_ecs_cluster.name
}

output "service_name" {
  value = aws_ecs_service.my_ecs_service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.my_task_definition.arn
}