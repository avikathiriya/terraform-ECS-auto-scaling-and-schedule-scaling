
resource "aws_security_group" "my_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  # Allow application traffic only from the ALB
  ingress {
    description     = "Application traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }

  lifecycle {
    create_before_destroy = true
  }
}