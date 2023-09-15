resource "aws_ecs_task_definition" "db_migration_task_definition" {
  family                   = "db-migration"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      "name"  : "db-migration-container",
      "image" : "db-migration:latest",
      "portMappings": [
        {
          "containerPort" : 5432
          # "hostPort"      : 80
        }
      ],
      "memory"         : 512,  # Specify the memory in MiB
      "memoryReservation": 256 
    },
    // You can define additional containers here if needed
  ])
}

resource "aws_ecs_service" "db_migration" {
  name            = "db-migration"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.db_migration_task_definition.arn
  desired_count   = 1
  
}

############################################################################################################

resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "frontend"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
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
    // You can define additional containers here if needed
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  
}

########################################################################################################

resource "aws_ecs_task_definition" "backend_task_definition" {
  family                   = "backend"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
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
  name            = "backend"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task_definition.arn
  desired_count   = 1
  
}
