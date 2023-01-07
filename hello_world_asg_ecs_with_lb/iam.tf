data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_agent.json}"
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = "${aws_iam_role.ecs_agent.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = "${aws_iam_role.ecs_agent.name}"
}


data "aws_iam_policy" "ecsServiceRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecsServiceRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsServiceRole" {
  name               = "ecsServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.ecsServiceRolePolicy.json}"
}

resource "aws_iam_role_policy_attachment" "ecsServicePolicy" {
  role       = "${aws_iam_role.ecsServiceRole.name}"
  policy_arn = "${data.aws_iam_policy.ecsServiceRolePolicy.arn}"
}



data "aws_iam_policy" "ecsTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecsExecutionRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.ecsExecutionRolePolicy.json}"
}
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionPolicy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "${data.aws_iam_policy.ecsTaskExecutionRolePolicy.arn}"
}