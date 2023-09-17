
resource "aws_ecs_task_definition" "backend_task_definition" {
  family                                = "backend"
  requires_compatibilities              = ["EC2"]
  container_definitions                 = jsonencode([
    {
      "name"  : "backend-container",
      "image" : "backend:latest",
      "portMappings": [
        {
          "containerPort" : 44369,
          "hostPort"      : 44369
        }
      ],
      "memory"         : 512,  # Specify the memory in MiB
      "memoryReservation": 256 
    },
    // You can define additional containers here if needed
  ])
}

resource "aws_ecs_service" "backend" {
    name                            = "backend"
    cluster                         = aws_ecs_cluster.ecs_cluster.id
    task_definition                 = aws_ecs_task_definition.backend_task_definition.arn
    desired_count                   = 1  
}

