variable "proxmox_api_url" {
  type        = string
  description = "The URL of the Proxmox API."
}

variable "proxmox_insecure_url" {
  type        = bool
  description = "Skip SSL verification of URL of the Proxmox API."
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The Proxmox API token secret."
  sensitive   = true
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The Proxmox API token id."
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to build the VM on."
}

variable "base_template_name" {
  type        = string
  description = "The name of the base template to clone from."
}

variable "template_name" {
  type        = string
  description = "The name of the template to create."
  default     = "ubuntu-2504-tailscale"
}

variable "template_description" {
  type        = string
  description = "The description for the template."
  default     = "Ubuntu 25.04 with Tailscale"
}

variable "template_version" {
  type        = string
  description = "The version of the image"
}

variable "vm_name" {
  type = string
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "rke2_version" {
  type = string
  default = "v1.31.1+rke2r1"
}

variable "ubuntu_pro_token" {
  type = string
  sensitive = true
}
