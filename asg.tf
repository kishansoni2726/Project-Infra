resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-0f5ee92e2d63afc18" # Ubuntu
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"
    
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
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
  autoscaling_group_name = aws_autoscaling_group.failure_analysis_ecs_asg.name
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