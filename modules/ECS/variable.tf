variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}
variable "container_name" {
  description = "The name of the container"
  type        = string
}
variable "container_image" {
  description = "The image of the container"
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "cpu" {
  type    = number
  default = "256"
}

variable "memory" {
  type    = number
  default = "512"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = true
}


variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}


