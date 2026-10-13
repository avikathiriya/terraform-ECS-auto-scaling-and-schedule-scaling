variable "sg_name" {
  type = string
}

variable "sg_description" {
  type = string
}
variable "app_port" {
  type    = number
  default = 8000
}
variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}
variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  type        = string
}