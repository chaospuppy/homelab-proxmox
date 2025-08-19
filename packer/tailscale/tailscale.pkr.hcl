packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "ubuntu-tailscale" {
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

  # Packer Connection Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
}

build {
  sources = ["source.proxmox-clone.ubuntu-tailscale"]

  provisioner "shell" {
    inline = [
      "echo 'Installing Tailscale...'",
      "curl -fsSL https://tailscale.com/install.sh | sudo sh",
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf",
      "sudo sysctl -p /etc/sysctl.d/99-tailscale.conf"
    ]
  }

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
