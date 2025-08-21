packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "ubuntu-rke2" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  insecure_skip_tls_verify = var.proxmox_insecure_url
  token                    = var.proxmox_api_token_secret
  username                 = var.proxmox_api_token_id

  # VM General Settings
  node                 = var.proxmox_node
  clone_vm             = var.base_template_name
  vm_name              = "${var.vm_name}-${var.template_version}"
  template_name        = "${var.template_name}-${var.template_version}"
  template_description = var.template_description
  onboot               = true

  memory = var.vm_memory

  # Packer Connection Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
}

build {
  sources = ["source.proxmox-clone.ubuntu-rke2"]
  
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    script          = "./scripts/os-prep.sh"
    timeout         = "15m"
  }
 
  provisioner "shell" {
    environment_vars = [
      "INSTALL_RKE2_VERSION=${var.rke2_version}",
      "ETCD_VERSION=${var.etcd_version}"
    ]
    // RKE2 artifact unpacking/install must be run as root
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    script          = "./scripts/rke2-install.sh"
    timeout         = "15m"
  }
  
  provisioner "file" {
    source = "./files"
    destination = "/tmp"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Path }}"
    script          = "./scripts/rke2-config.sh"
    timeout         = "15m"
  }

  provisioner "shell" {
    inline = [
      "echo 'Cleaning up image for template use...'",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /root/rke2-artifacts/etcd-${var.etcd_version}-linux-amd64/",
      "sudo cloud-init clean --logs --seed",
    ]
  }
}
