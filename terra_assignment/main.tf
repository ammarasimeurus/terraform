locals {
  reg    = var.reg
  owner  = terraform.workspace
  dbname = var.dbname
  dbpass = var.dbpass
}


provider "aws" {
  region = local.reg
}
terraform {
  backend "s3" {
    bucket         = "ammar-jenkins"
    key            = "terraform.tfstate"   # The name of your state file
    region         = local.reg
    encrypt        = false                  # Optionally enable encryption
  }
}
module "my_vpc" {
  source               = "./modules/vpc"
  for_each             = var.vpc_config
  region               = local.reg
  public_subnets_cidr  = each.value.public_subnets_cidr
  private_subnets_cidr = each.value.private_subnets_cidr
  enable_nat_gateway   = each.value.enable_nat_gateway
  vpc_cider            = each.value.vpc_cider
  vpc_name             = "${local.owner}-vpc"
  allowed_externals    = each.value.allowed_externals

}

module "rds" {
  source              = "./modules/rds"
  username            = local.dbname
  password            = local.dbpass
  instance_class      = "db.t2.micro"
  engine              = "mysql"
  publicly_accessible = true
  sg_name             = "${local.owner}-db-sg"
  public_subnet       = module.my_vpc.vpc_1.public_subnet_ids
  vpc_sg_id           = module.my_vpc.vpc_1.vpc_sg_id
  depends_on          = [module.my_vpc]
  owner               = local.owner
}

module "ecs" {

  source         = "./modules/ecs"
  dbname         = local.dbname
  dbpass         = local.dbpass
  owner          = local.owner
  endpoint       = module.rds.endpoint
  vpc_sg_id      = module.my_vpc.vpc_1.vpc_sg_id
  public_subnet  = module.my_vpc.vpc_1.public_subnet_ids
  my_vpc         = module.my_vpc.vpc_1.vpc_id
  private_subnet = module.my_vpc.vpc_1.private_subnet_ids
  img            = "public.ecr.aws/y2a9o9h4/ammar-ecr:latest"
  depends_on     = [module.rds]
}
