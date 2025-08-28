terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    region  = "us-west-1"
    bucket  = "homelab-lobster-proxmox-state"
    key     = "rke2.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "homelab-lobster-proxmox-state-lock"
  }
}

