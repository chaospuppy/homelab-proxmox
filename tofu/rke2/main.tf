provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true # Set to false if you have a valid certificate for Proxmox
}

# Note: For this to work, you need a cloud-init enabled template in Proxmox.
# The Proxmox QEMU Guest Agent should also be installed in the template
# for IP address reporting to work correctly.
resource "proxmox_vm_qemu" "rke2_server" {
  name        = var.vm_name
  target_node = var.proxmox_node
  clone       = var.template_name

  # VM hardware configuration
  cores   = var.vm_cores
  sockets = 1
  memory  = var.vm_memory

  # Cloud-Init configuration
  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"
  sshkeys   = var.ssh_public_key

  # Resize the disk. Change 'local-lvm' to your target storage.
  disk {
    type    = "scsi"
    storage = "local-lvm"
    size    = var.vm_disk_size
  }

  # Network configuration
  network {
    model  = "virtio"
    bridge = var.vm_bridge
  }

  # This is often needed when using cloud-init to prevent tofu from
  # trying to re-apply network settings on every run.
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
