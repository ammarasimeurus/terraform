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

 
