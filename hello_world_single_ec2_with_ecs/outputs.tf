output "instance_public_ip" {
	value = aws_instance.hello_world.public_ip
}