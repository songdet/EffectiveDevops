variable "my_vpc_id" {}
variable "my_subnet_id" {}

module "monolith_application" {
  source         = "./monolith-playground"
  my_region_id   = "us-east-1"
  my_vpc_id      = "${var.my_vpc_id}" 
  my_subnet      = "${var.my_subnet_id}"
  my_ami_id      = "ami-04681a1dbd79675a5"
  my_pem_keyname = "HomeLaptop"
}
