module "networking" {
  source               = "github.com/developmentseed/tf-seed/modules/networking"
  project_name         = var.project_name
  env                  = "${var.env}"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "${var.region}"
  availability_zones   = "${var.availability_zones}"
  tags                 = "${var.tags}"
}