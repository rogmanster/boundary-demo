terraform {
  required_version = ">= 0.12"
}

//Compute
provider "aws" {
  region = "us-west-2"
}

module "compute" {
  source = "./modules/compute"
  name   = "rchao"
  tags   = { Owner = "rchao@hashicorp.com", Region = "NAWESTSTRAT", TTL = "3" , Purpose = "Demo"}
}

//Boundary Config
//Issue: Unable to auth with auth_method_id
//Error: error calling read scope: {"kind":"Unauthenticated", "message":"Unauthenticated, or invalid token."}
provider "boundary" {
  addr                            = "http://${module.compute.boundary_public_ip}:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
  #token = file("${path.module}/boundary_token.txt")
}

module "boundary" {
  source = "./modules/boundary"

  backend_server_ips = module.compute.ubuntu_private_ip
  backend_windows_server_ips = module.compute.windows_private_ip
  boundary_server_ip = module.compute.boundary_private_ip
}
