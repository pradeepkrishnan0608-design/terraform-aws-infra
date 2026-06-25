module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr

  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr

  az_a = var.az_a
  az_b = var.az_b
}

module "security_group" {
  source = "../../modules/security-group"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "ec2" {
  source = "../../modules/ec2"

  environment = var.environment

  ami_id        = var.ami_id
  instance_type = var.instance_type

  subnet_id = module.vpc.public_subnet_a_id

  security_group_id = module.security_group.security_group_id
}
