resource "aws_key_pair" "key_pair" {
  key_name   = "${var.app_name}-key-pair"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "rsa_key_file" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${var.app_name}-key-pair.pem"
	file_permission = "0400"
}

resource "aws_instance" "hello_world" {
  ami                  = var.ec2_instance["ami"]
  subnet_id            = aws_subnet.public_a.id
  instance_type        = var.ec2_instance["type"]
  user_data            = <<EOF
	#!/bin/bash
	sudo yum update -y
	sudo amazon-linux-extras install nginx1 -y 
	sudo systemctl enable nginx
	sudo systemctl start nginx
	EOF
  security_groups      = [aws_security_group.ec2_sg.id]
  key_name             = aws_key_pair.key_pair.key_name

  tags = {
    Name = var.app_name
  }
}

resource "aws_alb" "nginx_alb" {
  name            = "${var.app_name}-lb"
  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups = [aws_security_group.elb_security_group.id]
}

resource "aws_alb_target_group" "nginx_tg" {
  name        = "${var.app_name}-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_nginx.id
  target_type = "ip"
}

resource "aws_alb_listener" "nginx_alb_listener" {
  load_balancer_arn = aws_alb.nginx_alb.arn
  port              = "80"
  protocol          = "HTTP"

	default_action {
    target_group_arn = aws_alb_target_group.nginx_tg.id
    type             = "forward"
  }
}
