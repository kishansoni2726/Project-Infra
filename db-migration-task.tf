resource "aws_ecs_task_definition" "db_migration_task_definition" {
  family                   = "db-migration"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      "name"  : "db-migration-container",
      "image" : "db-migration:latest",
      "essential": true,
      # "portMappings": [
      #   {
      #     "containerPort" : 5432
      #     # "hostPort"      : 80
      #   }
      # ],
      "memory"         : 512,  # Specify the memory in MiB
      "memoryReservation": 256 
    },
    // You can define additional containers here if needed
  ])
}

