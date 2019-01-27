variable "my_default_vpc_id" {}
variable "my_default_subnet_ids" {
  type = "list"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "rds" {
  name        = "allow_from_my_vpc"
  description = "Allow from my vpc"
  vpc_id      = "${var.my_default_vpc_id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "demodb"
  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  name     = "demodb"
  username = "monty"
  password = "some_pass"
  port     = "3306"

  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  # DB subnet group
  subnet_ids = "${var.my_default_subnet_ids}"
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  # DB parameter group
  family = "mysql5.7"
  # DB option group
  major_engine_version = "5.7"
}
