proxmox_api_url = "https://pve1.lobster.icu:8006/api2/json"
proxmox_insecure_url = true
proxmox_node = "pve2"
template_name = "vyos-1.4-2025.11"
vm_name = "vyos-packer"
template_version = "0.0.1"
template_description = "A VyOS template with SSH enabled for further configuration"
#iso_file = "local:iso/vyos-2025.11-generic-amd64.iso"
iso_file = "local:iso/vyos-live-image-cloudinit-qemu-agent.iso"
iso_type = "ide"
iso_checksum = "sha256:0d40621e15bc2169b3353e751628414e8e963be2cbb64f2bb7edc72ea4ceed75"
vm_cpu_cores = 2
vm_cpu_type = "host"
vm_memory = 8000
vm_disks = [
  {
    type = "scsi"
    size = "32G"
    storage_pool = "local-lvm"
  },
]
network_model = "virtio"
