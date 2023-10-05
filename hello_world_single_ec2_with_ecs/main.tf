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
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  user_data            = <<EOF
		#!/bin/bash
		echo ECS_CLUSTER=${var.app_name} >> /etc/ecs/ecs.config
	EOF
	user_data_replace_on_change = true
  security_groups      = [aws_security_group.ec2_sg.id]
  key_name             = aws_key_pair.key_pair.key_name

  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.app_name
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.app_name
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "host"
  container_definitions = jsonencode([
    {
      essential : true
      memory : var.container["memory"]
      name : var.app_name
      cpu : var.container["cpu"]
      image : "${aws_ecr_repository.ecr_repo.repository_url}:latest"
      environment : []
      portMappings : [
        {
          hostPort : var.container["port"],
          containerPort : var.container["port"],
          protocol : "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.container["count"]
  launch_type     = "EC2"
}
