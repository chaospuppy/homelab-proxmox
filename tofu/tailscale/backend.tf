terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    region  = "us-west-1"
    bucket  = "homelab-lobster-proxmox-state"
    key     = "tailscale.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "homelab-lobster-proxmox-state-lock"
  }
}

