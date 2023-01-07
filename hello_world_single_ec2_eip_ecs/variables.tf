variable "app_name" {
  type    = string
  default = "hello_world"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
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

variable "container" {
	type = map

	default = {
		"port" = 80
		"memory" = 512
		"cpu" = 2
		"count" = 1
	}
}

variable "vpc" {
	type = map
	default = {
		"vpc_cidr" = "10.0.0.0/16"
		"subnet1_cidr" = "10.0.1.0/24"
		"subnet2_cidr" = "10.0.2.0/24"
	}
}
