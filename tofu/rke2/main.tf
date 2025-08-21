provider "proxmox" {
  endpoint = var.proxmox_api_url
  insecure = var.proxmox_insecure_url

  username = var.proxmox_api_username
  password = var.proxmox_api_password
  # api_token = var.proxmox_api_token

  tmp_dir = "/var/tmp"

  ssh {
    agent       = false
    username    = var.machine_user
    private_key = file("~/.ssh/id_rsa")
  }
}

resource "proxmox_virtual_environment_vm" "tailscale" {
  name                = var.vm_name
  description         = "Managed by Tofu"
  node_name           = var.proxmox_node
  started             = var.started
  reboot_after_update = var.reboot_after_update
  # Migrate determines behavior when the node_name is changed
  migrate    = var.migrate
  protection = var.protection

  # System settings
  operating_system {
    type = var.operating_system
  }

  cpu {
    cores        = var.cpu_config.cores
    architecture = var.cpu_config.arch
    type         = var.cpu_config.type
  }

  clone {
    datastore_id = var.clone_config.datastore_id
    node_name    = var.clone_config.node_name
    retries      = var.clone_config.retries
    vm_id        = var.clone_config.vm_id
    full         = var.clone_config.full
  }

  agent {
    enabled = var.agent_config.enabled
    timeout = var.agent_config.timeout
    type    = var.agent_config.type

  }

  dynamic "disk" {
    for_each = var.disks
    content {
      aio          = disk.value.aio
      backup       = disk.value.backup
      cache        = disk.value.cache
      datastore_id = disk.value.datastore_id
      interface    = disk.value.interface
      size         = disk.value.size
    }
  }

  memory {
    dedicated = var.memory.dedicated
    floating  = var.memory.floating
    hugepages = var.memory.hugepages
  }

  # Network configuration
  dynamic "network_device" {
    iterator = nic
    for_each = var.network_devices
    content {
      bridge       = nic.value.bridge
      disconnected = nic.value.disconnected
      enabled      = nic.value.enabled
      firewall     = nic.value.firewall
      mac_address  = nic.value.mac_address
      model        = nic.value.model
      vlan_id      = nic.value.vlan_id
    }
  }

  connection {
    type        = var.connection_config.type
    agent       = var.connection_config.agent
    host        = element(element(self.ipv4_addresses, index(self.network_interface_names, var.connection_config.host_interface)), 0)
    private_key = file("~/.ssh/id_rsa")
    user        = var.machine_user
  }

  provisioner "remote-exec" {
    inline = [
      "sudo tailscale set --operator=$USER",
      "tailscale up --auth-key=${var.tailscale_auth_key}",
      "tailscale set --ssh",
      "tailscale set --hostname ${var.tailscale_hostname}",
      "tailscale set --advertise-exit-node --advertise-routes=${var.lobster_cidr}"
    ]
  }
}
