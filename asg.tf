resource "aws_ecr_repository" "db-migration" {
    name  = "db-migration"
}

resource "aws_ecr_repository" "frontend" {
    name  = "frontend"
}

resource "aws_ecr_repository" "backend" {
    name  = "backend"
}

resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "my-cluster"
}

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-054c337ee5048c313" # Amazon Linux with ECS compitable
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash \n echo ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"

    
}

resource "aws_autoscaling_group" "ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [ for subnet in aws_subnet.public_subnets[*] : subnet.id ]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name
    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 5
    health_check_grace_period = 300
    health_check_type         = "EC2"
    
}

resource "aws_lb" "alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_autoscaling_attachment" "asg_to_target_group" {
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  lb_target_group_arn  = aws_lb_target_group.lb_target_group.arn
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

#scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60" # New instance will be created once CPU utilization is higher than 30 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "constant_cpu_60_percent_up_alarm" {
  alarm_name          = "constant_cpu_60_percent_up_alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "20"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60" # New instance will be created once CPU utilization is higher than 30 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "20"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}

