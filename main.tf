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
    region         = "us-west-2"
    encrypt        = false                  # Optionally enable encryption
  }
}

  my_vpc         = module.my_vpc.vpc_1.vpc_id
  private_subnet = module.my_vpc.vpc_1.private_subnet_ids
  img            = "public.ecr.aws/y2a9o9h4/ammar-ecr:latest"
  depends_on     = [module.rds]
}
