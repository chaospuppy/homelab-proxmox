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

variable "vm_disks" {
  type = list(object(
    {
      size = string
      type = string
      storage_pool = string
    }
  ))
}

variable "network_model" {
  type = string
}

variable "network_bridge_interface" {
  type    = string
  default = "vmbr0"
}

variable "template_name" {
  type        = string
  description = "The name of the template to create."
  default     = "ubuntu-2204-base"
}

variable "template_description" {
  type        = string
  description = "The description for the template."
  default     = "Ubuntu 22.04 Base Image"
}

variable "template_version" {
  type        = string
  description = "The version of the image"
}

variable "vm_name" {
  type = string
}

variable "vm_cpu_cores" {
  type    = number
  default = 2
}

variable "vm_cpu_type" {
  type = string
}

variable "vm_memory" {
  type    = number
  default = 2048
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso"
}

variable "iso_file" {
  type = string
}

variable "iso_type" {
  type = string
  description = "Bus type that the ISO will be mounted on"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:11add4f24cf357a81000f74885a016335b98373317891754d0467512090ea4e9"
}
