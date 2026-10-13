output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "security_group_id" {
  value = module.sg.security_group_id
}


output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}