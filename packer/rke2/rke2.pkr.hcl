packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  vm_id_pve1 = var.starting_vm_id
  vm_id_pve2 = var.starting_vm_id + 1
  vm_id_pve3 = var.starting_vm_id + 2
}

source "proxmox-clone" "ubuntu-rke2-pve3" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  insecure_skip_tls_verify = var.proxmox_insecure_url
  token                    = var.proxmox_api_token_secret
  username                 = var.proxmox_api_token_id

  # VM General Settings
  node                 = "pve3"
  clone_vm             = var.base_template_name
  vm_name              = "${var.vm_name}-${var.template_version}"
  vm_id = local.vm_id_pve3
  template_name        = "${var.template_name}-${var.template_version}"
  template_description = var.template_description
  onboot               = true

  memory = var.vm_memory

  # Packer Connection Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
}

source "proxmox-clone" "ubuntu-rke2-pve2" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  insecure_skip_tls_verify = var.proxmox_insecure_url
  token                    = var.proxmox_api_token_secret
  username                 = var.proxmox_api_token_id

  # VM General Settings
  node                 = "pve2"
  clone_vm             = var.base_template_name
  vm_name              = "${var.vm_name}-${var.template_version}"
  vm_id = local.vm_id_pve2
  template_name        = "${var.template_name}-${var.template_version}"
  template_description = var.template_description
  onboot               = true

  memory = var.vm_memory

  # Packer Connection Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
}

source "proxmox-clone" "ubuntu-rke2-pve1" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  insecure_skip_tls_verify = var.proxmox_insecure_url
  token                    = var.proxmox_api_token_secret
  username                 = var.proxmox_api_token_id

  # VM General Settings
  node                 = "pve1"
  clone_vm             = var.base_template_name
  vm_name              = "${var.vm_name}-${var.template_version}"
  vm_id = local.vm_id_pve1
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
  sources = ["source.proxmox-clone.ubuntu-rke2-pve1","source.proxmox-clone.ubuntu-rke2-pve2","source.proxmox-clone.ubuntu-rke2-pve3"]
  
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
