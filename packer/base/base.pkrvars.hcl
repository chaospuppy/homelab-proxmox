proxmox_api_url = "https://pve1.lobster.icu:8006/api2/json"
proxmox_insecure_url = true
proxmox_node = "pve1"
template_name = "ubuntu-2504-base"
vm_name = "base"
template_version = "0.0.2"
template_description = "A base template that can be cloned from and used to provision other VMs"
iso_file = "local:iso/ubuntu-25.04-live-server-amd64.iso"
iso_type = "scsi"
iso_checksum = "sha256:8b44046211118639c673335a80359f4b3f0d9e52c33fe61c59072b1b61bdecc5"
vm_cpu_cores = 2
vm_cpu_type = "host"
vm_memory = 8000
vm_disks = [
  {
    type = "scsi"
    size = "100G"
    storage_pool = "local-lvm"
  },
]
network_model = "virtio"
