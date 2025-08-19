variable "proxmox_api_url" {
  type        = string
  description = "The URL of the Proxmox API (e.g. https://proxmox.example.com:8006/api2/json)."
  sensitive   = true
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The Proxmox API token ID (e.g. user@pve!token)."
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The Proxmox API token secret."
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to deploy the VM on."
}

variable "template_name" {
  type        = string
  description = "The name of the VM template to clone."
}

variable "vm_name" {
  type        = string
  description = "The name for the new VM."
  default     = "rke2-server-1"
}

variable "vm_cores" {
  type        = number
  description = "Number of CPU cores for the VM."
  default     = 2
}

variable "vm_memory" {
  type        = number
  description = "Amount of RAM in MB for the VM."
  default     = 4096
}

variable "vm_disk_size" {
  type        = string
  description = "Disk size for the VM (e.g., '20G')."
  default     = "20G"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to inject into the VM for access."
  sensitive   = true
}

variable "vm_bridge" {
  type        = string
  description = "Proxmox network bridge for the VM."
  default     = "vmbr0"
}
