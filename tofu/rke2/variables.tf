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

variable "persistent_admin_username" {
  type = string
}

variable "persistent_admin_password" {
  type      = string
  sensitive = true
}

variable "debug" {
  type        = bool
  default     = false
  description = "If debug is enabled, then the token generated from Rancher will not be marked sensative, allowing more complete logging."
}

variable "rke2_nodes" {
  type = map(object({
    clone_config = optional(object({
      datastore_id = optional(string, "local-lvm")
      node_name    = optional(string, null)
      retries      = optional(number, 3)
      vm_id        = optional(number, 100)
      full         = optional(bool, true)
    }), {}),
    proxmox_node = string,
    cpu_config = optional(object({
      cores = optional(string, 4)
      arch  = optional(string, "x86_64")
      type  = optional(string, "host")
      numa  = optional(bool, false)
    }), {}),
    memory_config = optional(object({
      dedicated = optional(number, 512)
      floating  = optional(number, 512)
      hugepages = optional(number, null)
    }), {}),
    os = optional(string, "l26"),
    network_devices = optional(list(object({
      bridge       = optional(string, "vmbr0")
      disconnected = optional(bool, false)
      enabled      = optional(bool, true)
      firewall     = optional(bool, false)
      mac_address  = optional(string, null)
      model        = optional(string, "virtio")
      vlan_id      = optional(string, null)
    })), []),
    disks_config = optional(list(object({
      aio          = optional(string, "native")
      backup       = optional(bool, false)
      cache        = optional(string, "none")
      datastore_id = optional(string, "local-lvm")
      interface    = optional(string, "scsi2")
      size         = optional(number, 50)
      device_name  = optional(string, null)
    })), []),
    agent_config = optional(object({
      enabled = optional(bool, true)
      timeout = optional(string, "15m")
      type    = optional(string, "virtio")
    }), {}),
    ansible_info = object(
      {
        group = string
        host_vars = object({
          is_primary          = optional(bool, false)
          cloud_provider      = optional(string)
          node_taints         = optional(list(string))
          kube_apiserver_args = optional(list(string))
        })
      }
    ),
    connection_config = optional(object({
      type           = optional(string, "ssh")
      agent          = optional(bool, false)
      host_interface = optional(string, "ens18")
    }), {})

  }))
  description = "Map of RKE2 nodes with configurations including template name, CPU count, memory size, operating system, network settings, disk configuration, and Ansible information."

  validation {
    condition     = length([for node in var.rke2_nodes : 1 if node.ansible_info.group == "controlplane" && node.ansible_info.host_vars.is_primary]) == 1
    error_message = "Exactly one control plane node must be set as the primary node."
  }
}

variable "machine_user" {
  type    = string
  default = "chaospuppy"
}

variable "migrate" {
  type    = bool
  default = false
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
