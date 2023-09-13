resource "aws_ecr_repository" "worker" {
    name  = "nginx"
}

resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "my-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "nginx"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      "name"  : "example-container",
      "image" : "nginx:latest",
      "portMappings": [
        {
          "containerPort" : 80,
          "hostPort"      : 80
        }
      ],
      "memory"         : 256,  # Specify the memory in MiB
      "memoryReservation": 128 
    }
    // You can define additional containers here if needed
  ])
}

resource "aws_ecs_service" "worker" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
}
