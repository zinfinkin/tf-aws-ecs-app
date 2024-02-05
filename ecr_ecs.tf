# Elastic Container Repository - where the container image is stored. 
resource "aws_ecr_repository" "aws-ecr" {
  name = "${var.name}-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "${var.name}-ecr"
  }
}

# Elastic Container Service (ECS) - platform for managing containers.
# Setting up as FARGATE type, meaning we don't have to manage the hosts. AWS manages the hosts for us. 
resource "aws_ecs_cluster" "primary" {
  name = "${var.name}-cluster"
  tags = {
    Name        = "${var.name}-ecs"
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.name}"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.name}-container",
      "image": "${var.name}-ecr:latest",
      "entryPoint": [],
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8081,
          "hostPort": 8081
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "${var.name}-ecs-td"
  }
}

# Data source that exports the family name of the ECS task definition. 
# Might not be needed, cannot recall why I added this. Ha! 
data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

# ECS service - the platform for our task definition within ECS. Runs our tasks (Containers).
resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.name}-ecs-service"
  cluster              = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.aws-ecs-task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 2


  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.name}-container"
    container_port   = 8081
  }

  depends_on = [aws_lb_listener.https]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

# Security group managing access to ECS. Ingress allows all communication but ONLY from resources which have the below security group attached to them. 
resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-service-sg"
  }
}

# ECS IAM Role allowing our ECS cluster to manage tasks. 
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.name}-iam-role"
  }
}

# Data source getting permissions from the below specified service role. 
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Attaches the policy created above to the role also created above. 
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}