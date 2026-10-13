
# ============================================================
# ECS Application Auto Scaling Target
# ============================================================

resource "aws_appautoscaling_target" "ecs_target" {
  min_capacity       = 1
  max_capacity       = 4
  resource_id        = "service/${var.app_name}-cluster/avi-ecs-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [module.ecs]
}

# ============================================================
# CPU-Based Target Tracking
# ============================================================

resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${var.app_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 120
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# ============================================================
# Memory-Based Target Tracking
# ============================================================

resource "aws_appautoscaling_policy" "memory_scaling" {
  name               = "${var.app_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70
    scale_in_cooldown  = 120
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

# ============================================================
# ALB Request Count-Based Target Tracking
# ============================================================

resource "aws_appautoscaling_policy" "request_scaling" {
  name               = "${var.app_name}-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    # Example starting target; tune after load testing.
    # Requests per target per minute.
    target_value       = 1000
    scale_in_cooldown  = 120
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${aws_lb.ecs_alb.arn_suffix}/${aws_lb_target_group.ecs_tg.arn_suffix}"
    }
  }
}

# ============================================================
# Scheduled Scaling: Every Day at 3:00 PM IST
# Keep at least 3 tasks; allow scaling up to 4.
# ============================================================

resource "aws_appautoscaling_scheduled_action" "scale_up_3pm" {
  name               = "${var.app_name}-scale-up-3pm"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  schedule = "cron(0 15 * * ? *)"
  timezone = "Asia/Kolkata"

  scalable_target_action {
    min_capacity = 3
    max_capacity = 4
  }
}

# ============================================================
# Scheduled Scaling: Every Day at 3:30 PM IST
# Force exactly one task.
# ============================================================

resource "aws_appautoscaling_scheduled_action" "scale_down_330pm" {
  name               = "${var.app_name}-scale-down-330pm"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  schedule = "cron(30 15 * * ? *)"
  timezone = "Asia/Kolkata"

  scalable_target_action {
    min_capacity = 1
    max_capacity = 1
  }
}

# ============================================================
# Scheduled Scaling: Every Day at 3:31 PM IST
# Restore metric-based scaling from 1 to 4 tasks.
# ============================================================

resource "aws_appautoscaling_scheduled_action" "resume_autoscaling_331pm" {
  name               = "${var.app_name}-resume-autoscaling-331pm"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  schedule = "cron(45 14 * * ? *)"
  timezone = "Asia/Kolkata"

  scalable_target_action {
    min_capacity = 1
    max_capacity = 4
  }
}
