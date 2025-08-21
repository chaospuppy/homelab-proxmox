module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version                            = "1.7.0"
  namespace                          = "homelab"
  stage                              = "lobster"
  name                               = "proxmox"
  attributes                         = ["state"]
  arn_format                         = "arn:aws"
  force_destroy                      = false
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
}
