#Define the ecr repo
resource "aws_ecr_repository" "my_repository" {
  name = "my-ecr-repo"  
}
#Define the ecs cluster
resource "aws_ecs_cluster" "Cluster" {
  name = "my-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

##Define the ecs task defenition
resource "aws_ecs_task_definition" "demo_app_task" {
  family                   = var.demo_app_task_famliy
 
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.demo_app_task_name}",
      "image": "${var.ecr_repo_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "demo_app_service" {
  name            = var.demo_app_service_name
  cluster         = aws_ecs_cluster.Cluster.id
  task_definition = aws_ecs_task_definition.demo_app_task.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.demo_app_task.family
    container_port   = var.container_port
  }
  force_new_deployment = true
  placement_constraints {
   type = "distinctInstance"
 }
 triggers = {
   redeployment = timestamp()
 }
 capacity_provider_strategy {
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
   weight            = 100
 }
  network_configuration {
    subnets          = ["${aws_subnet.private-subnet-3.id}", "${aws_subnet.private-subnet-4.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
  depends_on = [aws_autoscaling_group.ecs_asg]
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
