terraform {
  required_version = ">= v1.9.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.81.0"
    }
  }
}
