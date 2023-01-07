resource "aws_ecr_repository" "ecr_repo" {
  name = var.app_name
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.app_name}-key-pair"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rsa_key_file" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${var.app_name}-key-pair.pem"
}

resource "aws_instance" "hello_world" {
  ami                  = var.ec2_instance["ami"]
  subnet_id            = aws_subnet.public_a.id
  instance_type        = var.ec2_instance["type"]
  iam_instance_profile = aws_iam_instance_profile.ecs_instance.name
  user_data            = file("user_data.txt")
  security_groups      = [aws_security_group.ec2_sg.id]
  key_name             = aws_key_pair.key_pair.key_name

  tags = {
    Name = "example_app"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "worker"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  network_mode             = "host"
  container_definitions = jsonencode([
    {
      essential : true
      memory : 512
      name : "example_app"
      cpu : 2
      image : "${aws_ecr_repository.ecr_repo.repository_url}:latest"
      environment : []
      portMappings : [
        {
          hostPort : 80,
          containerPort : 80,
          protocol : "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.example_app_tg.arn
  #   container_name   = "example_app"
  #   container_port   = 80
  # }
  # network_configuration {
  #   security_groups  = [aws_vpc.vpc_example_app.default_security_group_id]
  #   subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  #   assign_public_ip = "false"
  # }
}

resource "aws_lb" "example_app_lb" {
  name            = "example-app-lb"
  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups = [aws_security_group.elb_security_group.id]
}

resource "aws_lb_target_group" "example_app_tg" {
  name        = "example-app-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_example_app.id
  target_type = "ip"
}

resource "aws_lb_listener" "example_app_lb_listener" {
  load_balancer_arn = aws_lb.example_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

	default_action {
    target_group_arn = aws_lb_target_group.example_app_tg.id
    type             = "forward"
  }
}
