
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                                    = "frontend"
  requires_compatibilities                  = ["EC2"]
  container_definitions                     = jsonencode([
    {
      "name"  : "frontend-container",
      "image" : "frontend:latest",
      "portMappings": [
        {
          "containerPort" : 80,
          "hostPort"      : 80
        }
      ],
      "memory"         : 512,  # Specify the memory in MiB
      "memoryReservation": 256 
    },
  ])
}

resource "aws_ecs_service" "frontend" {
  name                                    = "frontend"
  cluster                                 = aws_ecs_cluster.ecs_cluster.id
  task_definition                         = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count                           = 1 
}

