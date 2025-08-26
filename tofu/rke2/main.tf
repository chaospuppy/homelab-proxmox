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

locals {
  # Generate RKE2 token based on debug mode
  rke2_token = var.debug ? random_string.rke2_token[0].result : random_password.rke2_token[0].result

  # Extract Ansible groups from nodes
  groups = toset([for node in var.rke2_nodes : node.ansible_info.group])

  # Map groups to IPs of their respective nodes
  group_to_ip = {
    for group in local.groups :
    group => [
      for node_name, node_details in var.rke2_nodes : proxmox_virtual_environment_vm.rke2[node_name].ipv4_addresses[1][0]
      if node_details.ansible_info.group == group
    ]
  }

  # Map node names to their ansible hostvars
  node_to_vars = {
    for node in keys(var.rke2_nodes) : node => var.rke2_nodes[node].ansible_info.host_vars
  }
}

resource "random_string" "rke2_token" {
  count   = var.debug == true ? 1 : 0
  length  = 16
  special = false
}

resource "random_password" "rke2_token" {
  count   = var.debug == false ? 1 : 0
  length  = 16
  special = false
}

resource "proxmox_virtual_environment_vm" "rke2" {
  for_each            = var.rke2_nodes
  name                = each.key
  description         = "Managed by Tofu"
  node_name           = each.value.proxmox_node
  started             = var.started
  reboot_after_update = var.reboot_after_update
  # Migrate determines behavior when the node_name is changed
  migrate    = var.migrate
  protection = var.protection

  # System settings
  operating_system {
    type = each.value.os
  }

  cpu {
    cores        = each.value.cpu_config.cores
    architecture = each.value.cpu_config.arch
    type         = each.value.cpu_config.type
    numa         = each.value.cpu_config.numa
  }

  clone {
    datastore_id = each.value.clone_config.datastore_id
    node_name    = each.value.clone_config.node_name
    retries      = each.value.clone_config.retries
    vm_id        = each.value.clone_config.vm_id
    full         = each.value.clone_config.full
  }

  agent {
    enabled = each.value.agent_config.enabled
    timeout = each.value.agent_config.timeout
    type    = each.value.agent_config.type
  }

  dynamic "disk" {
    for_each = each.value.disks_config
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
    dedicated = each.value.memory_config.dedicated
    floating  = each.value.memory_config.floating
    hugepages = each.value.memory_config.hugepages
  }

  # Network configuration
  dynamic "network_device" {
    iterator = nic
    for_each = each.value.network_devices
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
    type        = each.value.connection_config.type
    agent       = each.value.connection_config.agent
    host        = element(element(self.ipv4_addresses, index(self.network_interface_names, each.value.connection_config.host_interface)), 0)
    private_key = file("~/.ssh/id_rsa")
    user        = var.machine_user
  }
}

resource "local_sensitive_file" "host_vars" {
  for_each = local.node_to_vars
  # Ansible will look for host variables in files that are named after the host they apply to.
  # Right now, without DNS, the host names are the IP addresses themselves, so name the file as the node IP address.
  filename = "./ansible/host_vars/${proxmox_virtual_environment_vm.rke2[each.key].ipv4_addresses[1][0]}"
  content = yamlencode(
    merge(
      each.value,
      {
        "hostname" = each.key,
      }
    )
  )
}

resource "local_file" "ansible_inventory" {
  content  = templatefile("./files/ansible-inventory.yaml.tftpl.hcl", { groups = local.group_to_ip })
  filename = "ansible/ansible-inventory"
}

resource "terraform_data" "ansible" {
  triggers_replace = concat(
    values({ for key, vm in proxmox_virtual_environment_vm.rke2 : key => vm.mac_addresses[1] }),
    [local_file.ansible_inventory.content_md5],
    values({ for key, file in local_sensitive_file.host_vars : key => file.content_md5 })
  )

  provisioner "local-exec" {
    working_dir = "./ansible/"
    command     = <<EOT
    sleep 20 && ansible-playbook playbook.yaml -i ./ansible-inventory -v \
      --ssh-extra-args="-o Ciphers='aes256-ctr,aes192-ctr,aes128-ctr' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
      --extra-vars "ansible_ssh_timeout=60 ansible_user=${var.persistent_admin_username} ansible_password=${var.persistent_admin_password} rke2_token=${local.rke2_token}" -b
    EOT
  }
  depends_on = [
    local_sensitive_file.host_vars,
    local_file.ansible_inventory
  ]
}

