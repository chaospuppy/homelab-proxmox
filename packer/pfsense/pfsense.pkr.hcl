packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "pfsense-pve1" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  insecure_skip_tls_verify = var.proxmox_insecure_url
  token                    = var.proxmox_api_token_secret
  username                 = var.proxmox_api_token_id

  # VM General Settings
  #node                 = var.proxmox_node
  node = "pve1"
  vm_name              = "${var.vm_name}-${var.template_version}"
  template_name        = "${var.template_name}-${var.template_version}"
  template_description = var.template_description

  # VM OS Settings
  boot_iso {
    type             = var.iso_type
    iso_file         = var.iso_file
    iso_checksum     = var.iso_checksum
    unmount              = true
  }

  # VM Hardware Settings
  cores           = var.vm_cpu_cores
  cpu_type        = var.vm_cpu_type
  memory          = var.vm_memory
  scsi_controller = "virtio-scsi-pci"

  dynamic "disks" {
    for_each = var.vm_disks
    content {
      type              = disks.value["type"]
      disk_size         = disks.value["size"]
      storage_pool      = disks.value["storage_pool"]
    }
  }

  network_adapters {
    model  = var.network_model
    bridge = var.network_bridge_interface
  }

  # Cloud-Init Settings for unattended install
  additional_iso_files {
    iso_storage_pool = "local"
    type = "scsi"
    cd_content = {
      "/user-data" = file("${abspath(path.root)}/http/user-data")
      "/meta-data" = ""
    }
    cd_label = "cidata"
    unmount = true
  }
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud",
    "<wait><F10><wait>"
  ]

  # Packer Connection Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
}

build {
  sources = ["source.proxmox-iso.ubuntu-base-pve1"]

  provisioner "shell" {
    inline = [
      "echo 'Cleaning up image for template use...'",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo cloud-init clean --logs --seed",
    ]
  }
}
