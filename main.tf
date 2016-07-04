provider "aws" { }

variable "app_name" {}
variable "service_name" {}
variable "app_service_name" {}

resource "aws_subnet" "subnet" {
  count = "${var.az_count}"

  vpc_id = "${data.terraform_remote_state.env.vpc_id}"

  availability_zone = "${element(data.terraform_remote_state.global.az_names,count.index)}"
  cidr_block = "${element(var.cidr_blocks, count.index)}"

  tags {
    "Provisioner" = "tf"
  }

  lifecycle {
    create_before_destroy = false
  }
}

output "subnet_ids" {
  value = [ "${aws_subnet.subnet.*.id}" ]
}

resource "aws_security_group" "sg" {
  name = "${var.context_org}-${var.context_env}-${var.app_service_name}"
  description = "Service ${var.app_service_name}"

  vpc_id = "${data.terraform_remote_state.env.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    "App" = "${var.app_name}"
		"Service" = "${var.app_service_name}"
    "Provisioner" = "tf"
  }
}