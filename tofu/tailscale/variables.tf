variable "proxmox_api_url" {
  type        = string
  description = "The URL of the Proxmox API (e.g. https://proxmox.example.com:8006/)."
}

variable "proxmox_insecure_url" {
  type    = bool
  default = true
}

# API token authentication does not provide full API access
# variable "proxmox_api_token" {
#   type        = string
#   description = "The Proxmox API token id and secret."
#   sensitive   = true
#   default = ""
# }

variable "proxmox_api_username" {
  type        = string
  description = "Username of the user used by Tofu to create resources"
  sensitive   = true
}

variable "proxmox_api_password" {
  type        = string
  description = "Password of the user used by Tofu to create resources"
  sensitive   = true
}

variable "tailscale_auth_key" {
  type        = string
  description = "Password of the user used by Tofu to create resources"
  sensitive   = false
}

variable "tailscale_hostname" {
  type    = string
  default = "lobster-exit-node"
}

variable "lobster_cidr" {
  type = string
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to deploy the VM on."
}
variable "machine_user" {
  type    = string
  default = "chaospuppy"
}

variable "clone_config" {
  type = object({
    datastore_id = optional(string, "local-lvm")
    node_name    = optional(string, null)
    retries      = optional(number, 3)
    vm_id        = optional(number, 100)
    full         = optional(bool, true)
  })
  default = {}
}

variable "cpu_config" {
  type = object({
    cores = optional(string, 4)
    arch  = optional(string, "x86_64")
    type  = optional(string, "host")
  })
  default = {}
}

variable "disks" {
  type = list(object({
    aio          = optional(string, "native")
    backup       = optional(bool, false)
    cache        = optional(string, "none")
    datastore_id = optional(string, "local-lvm")
    interface    = optional(string, "scsi2")
    size         = optional(number, 50)
  }))
  default = [{}]
}

variable "memory" {
  type = object({
    dedicated = optional(number, 512)
    floating  = optional(number, 512)
    hugepages = optional(number, null)
  })
  default = {}
}

variable "network_devices" {
  type = list(object({
    bridge       = optional(string, "vmbr0")
    disconnected = optional(bool, false)
    enabled      = optional(bool, true)
    firewall     = optional(bool, false)
    mac_address  = optional(string, null)
    model        = optional(string, "virtio")
    vlan_id      = optional(string, null)
  }))
  default = [{}]
}

variable "migrate" {
  type    = bool
  default = false
}

variable "vm_name" {
  type        = string
  description = "The name for the new VM."
  default     = "tailscale"
}

variable "operating_system" {
  type        = string
  description = "The OS type for the VM"
  default     = "l26"
}

variable "agent_config" {
  type = object({
    enabled = optional(bool, true)
    timeout = optional(string, "15m")
    type    = optional(string, "virtio")
  })
  default = {}
}

variable "protection" {
  type    = bool
  default = false
}

variable "started" {
  type    = bool
  default = true
}

variable "reboot_after_update" {
  type    = bool
  default = true
}

variable "connection_config" {
  type = object({
    type           = optional(string, "ssh")
    agent          = optional(bool, false)
    host_interface = optional(string, "ens18")
  })
  default = {}
}
