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

resource "proxmox_virtual_environment_vm" "docker_registry" {
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
      "mkdir -p ~/docker-registry/auth ~/docker-registry/certs ~/docker-registry/image-storage",
      "echo 'zarf-pull:${bcrypt(var.zarf_registry_pull_password)}' > ~/docker-registry/auth/creds",
      "echo 'zarf-push:${bcrypt(var.zarf_registry_push_password)}' >> ~/docker-registry/auth/creds",
    ]
  }

  provisioner "file" {
    source      = "../../bundle/tls/tenant.crt"
    destination = "/home/${var.machine_user}/docker-registry/certs/tenant.crt"
  }

  provisioner "file" {
    source      = "../../bundle/tls/tenant.key"
    destination = "/home/${var.machine_user}/docker-registry/certs/tenant.key"
  }

  provisioner "remote-exec" {
    inline = [
      "docker run --restart always -e REGISTRY_LOG_LEVEL=debug -e REGISTRY_AUTH='htpasswd' -e REGISTRY_AUTH_HTPASSWD_REALM='Registry Realm' -e REGISTRY_AUTH_HTPASSWD_PATH='/auth/creds' -e REGISTRY_HTTP_TLS_CERTIFICATE='/certs/tenant.crt' -e REGISTRY_HTTP_TLS_KEY='/certs/tenant.key' -d -p 5000:5000 -v $HOME/docker-registry/auth/:/auth -v $HOME/docker-registry/certs/:/certs -v $HOME/docker-registry/image-storage/:/var/lib/registry registry:${var.distribution_version}",
    ]
  }
}
