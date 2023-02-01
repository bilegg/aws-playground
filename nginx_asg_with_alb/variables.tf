variable "app_name" {
  type    = string
  default = "nginx"
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
		"ami" = "ami-0b752bf1df193a6c4"
		"type" = "t1.micro"
		"open_ports" = [22, 80, 443]
	}
}

variable "vpc" {
	type = map
	default = {
		"cidr" = "10.0.0.0/16"
	}
}
