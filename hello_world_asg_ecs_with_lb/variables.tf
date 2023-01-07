variable "app_name" {
  type    = string
  default = "hello_world"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_AMI" {
  type    = string
  default = "ami-07d934297995acaca"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_instance" {
	type = object({
    ami = string
    type = string
    open_ports = list(number)
  })

	default = {
		"ami" = "ami-07d934297995acaca"
		"type" = "t2.micro"
		"open_ports" = [22, 80, 443]
	}
}

variable "vpc" {
	type = map
	default = {
		"cidr" = "10.0.0.0/16"
	}
}
