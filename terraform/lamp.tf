provider "aws" {
  region = "us-west-2"
  # default location is $HOME/.aws/credentials
  profile = "lamp"
}

data "aws_caller_identity" "current" {
  # no arguments
}

resource "aws_vpc" "lamp" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "LAMP"
  }
}

module "webserver" {
  source = "modules/webserver"

  vpc_id = "${aws_vpc.lamp.id}"
  vpc_cidr = "${aws_vpc.lamp.cidr_block}"
  ami_owner_id = "${data.aws_caller_identity.current.account_id}"
  azs = "${var.azs}"
}

module "database" {
  source = "modules/database"

  vpc_id = "${aws_vpc.lamp.id}"
  vpc_cidr = "${aws_vpc.lamp.cidr_block}"
  azs = "${var.azs}"

  # other module dependencies
  webserver_cidrs = "${module.webserver.webserver_cidrs}"
}

variable "azs" {
  type = "list"
  default = ["us-west-2a", "us-west-2b"]
}
