variable "owner" {
  
}
variable "dbname" {
  
}
variable "dbpass" {
  
}
variable "endpoint" {
  
}
variable "vpc_sg_id" {
  
}

variable "public_subnet" {
  
}
variable "private_subnet" {
  
}
variable "my_vpc" {
  type = string
}
variable "img" {
  
}

resource "aws_ecs_cluster" "this" {
  name = var.owner
}


# Create an ECS Task Definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" # 0.25 vCPU
  memory                   = "3072" # 0.5 GB
  runtime_platform {
        cpu_architecture = "X86_64"
        operating_system_family = "LINUX"
  }
  

  execution_role_arn = "arn:aws:iam::489994096722:role/ecsTaskExecutionRole" # Replace with your ECS task execution role ARN
  task_role_arn = "arn:aws:iam::489994096722:role/ECS_Role"
  container_definitions = jsonencode([{
    name  = var.owner ,
    image = var.img # Use the ECR repository URL
    environment = [
      {
        name  = "dbname",
        value = var.dbname,
      },
      {
        name  = "dbpass",
        value = var.dbpass,
      },
      {
        name  = "PrivateIP",
        value = var.endpoint,
      }
    ]
    "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
          
        }
      ]
  }])
     tags = {
    Name = var.owner
  }
}


# Create an Application Load Balancer
resource "aws_lb" "my_alb" {
  name               =  var.owner
  internal           = false
  load_balancer_type = "application"
  
  security_groups    = [var.vpc_sg_id] # Replace with your security group ID
  subnets            = [var.public_subnet[0].id,var.public_subnet[1].id,var.public_subnet[2].id] # Replace with your subnet IDs
   tags = {
    Name = var.owner
  }
}


# Create a Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     =  var.owner
  port     = 80
  protocol = "HTTP"
  
  target_type = "ip" # Set target type to "ip"
  vpc_id   = var.my_vpc # Replace with your VPC ID
  health_check {
      healthy_threshold   = "3"
      interval            = "60"
      unhealthy_threshold = "5"
      timeout             = "30"
      path                = "/"
      port                = "80"
      
  }
   tags = {
    Name = var.owner
  }
}

resource "aws_lb_listener" "lb_listener_http" {
   load_balancer_arn    = aws_lb.my_alb.arn
   port                 = "80"
   protocol             = "HTTP"
   default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
   tags = {
    Name = var.owner
  }
}
# Create an ECS Service
resource "aws_ecs_service" "my_service" {
  name            = var.owner
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count   = 3
  health_check_grace_period_seconds = 60
  network_configuration {
    # subnets = ["subnet-0ee74aa3b4fb3fa40", "subnet-008e5d77360ac6ab6"]
    #  security_groups = ["sg-00445a7d87bb2ad45"]
    subnets = [var.private_subnet[0].id,var.private_subnet[1].id] # Replace with your subnet IDs
    security_groups = [var.vpc_sg_id] # Replace with your security group ID
  }

    load_balancer {
      target_group_arn = aws_lb_target_group.my_target_group.arn # Replace with your target group ARN
      container_name   = var.owner
      container_port   = 80
      
    }
  tags = {
    Name = var.owner
  }
  depends_on = [aws_ecs_task_definition.my_task_definition]
}
