resource "aws_launch_configuration" "ecs_launch_config" {
    name                              = "${var.project}-Launch-config"
    image_id                          = var.AMI
    iam_instance_profile              = aws_iam_instance_profile.ecs_agent.name
    security_groups                   = [aws_security_group.ecs_sg.id]
    user_data                         = var.lg_user_data
    instance_type                     = var.asg_instance_type
    key_name                          = var.key_name
}

resource "aws_autoscaling_group" "ecs_asg" {
    name                              = "${var.project}-ASG"
    vpc_zone_identifier               = [ for subnet in aws_subnet.public_subnets[*] : subnet.id ]
    launch_configuration              = aws_launch_configuration.ecs_launch_config.name
    desired_capacity                  = var.desired_capacity
    min_size                          = var.min_size
    max_size                          = var.max_size
    health_check_grace_period         = var.health_check_grace_period
    health_check_type                 = "EC2"
}

resource "aws_lb" "alb" {
    name                              = "${var.project}-Public-ALB"
    internal                          = false
    load_balancer_type                = "application"
    security_groups                   = [aws_security_group.ecs_sg.id]
    subnets                           = [for subnet in aws_subnet.public_subnets : subnet.id]
    tags = {
        Createdwith                   = "Terraform"
    }
}

resource "aws_lb_target_group" "lb_target_group" {
    name                              = "${var.project}-Target-Group"
    port                              = 80
    protocol                          = "HTTP"
    vpc_id                            = aws_vpc.main.id
    target_type                       = "instance"
    tags = {
        Createdwith                   = "Terraform"
    } 
}

resource "aws_autoscaling_attachment" "asg_to_target_group" {
    autoscaling_group_name            = aws_autoscaling_group.ecs_asg.name
    lb_target_group_arn               = aws_lb_target_group.lb_target_group.arn
}

resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn                 = aws_lb.alb.arn
    port                              = "80"
    protocol                          = "HTTP"
    default_action {
        type                          = "forward"
        target_group_arn              = aws_lb_target_group.lb_target_group.arn
    }
}

#scale up policy
resource "aws_autoscaling_policy" "scale_up" {
    name                              = "${var.project}-asg-scale-up"
    autoscaling_group_name            = aws_autoscaling_group.ecs_asg.name
    adjustment_type                   = "ChangeInCapacity"
    scaling_adjustment                = "1" #increasing instance by 1 
    cooldown                          = "300"
    policy_type                       = "SimpleScaling"
}

# scale up alarm
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
    alarm_name                        = "${var.project}-asg-scale-up-alarm"
    alarm_description                 = "asg-scale-up-cpu-alarm"
    comparison_operator               = "GreaterThanOrEqualToThreshold"
    evaluation_periods                = "5"
    metric_name                       = "CPUUtilization"
    namespace                         = "AWS/EC2"
    period                            = "60"
    statistic                         = "Average"
    threshold                         = "60" 
    dimensions = {
      "AutoScalingGroupName" = aws_autoscaling_group.ecs_asg.name
    }
    actions_enabled                   = true
    alarm_actions                     = [aws_autoscaling_policy.scale_up.arn]
}

# Alarm for average CPU Utilization og greater than 60% for constant 20 minutes
resource "aws_cloudwatch_metric_alarm" "constant_cpu_60_percent_up_alarm" {
    alarm_name                        = "${var.project}-constant_cpu_60_percent_up_alarm"
    alarm_description                 = "asg-scale-up-cpu-alarm"
    comparison_operator               = "GreaterThanOrEqualToThreshold"
    evaluation_periods                = "20"
    metric_name                       = "CPUUtilization"
    namespace                         = "AWS/EC2"
    period                            = "60"
    statistic                         = "Average"
    threshold                         = "60" 
    dimensions = {
      "AutoScalingGroupName"          = aws_autoscaling_group.ecs_asg.name
    }
    actions_enabled                   = true
    alarm_actions                     = [aws_autoscaling_policy.scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
    name                              = "${var.project}-asg-scale-down"
    autoscaling_group_name            = aws_autoscaling_group.ecs_asg.name
    adjustment_type                   = "ChangeInCapacity"
    scaling_adjustment                = "-1" # decreasing instance by 1 
    cooldown                          = "300"
    policy_type                       = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
    alarm_name                        = "${var.project}-asg-scale-down-alarm"
    alarm_description                 = "asg-scale-down-cpu-alarm"
    comparison_operator               = "LessThanOrEqualToThreshold"
    evaluation_periods                = "20"
    metric_name                       = "CPUUtilization"
    namespace                         = "AWS/EC2"
    period                            = "60"
    statistic                         = "Average"
    threshold                         = "40"
    dimensions = {
      "AutoScalingGroupName"          = aws_autoscaling_group.ecs_asg.name
    }
    actions_enabled                   = true
    alarm_actions                     = [aws_autoscaling_policy.scale_down.arn]
}

