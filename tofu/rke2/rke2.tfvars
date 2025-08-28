proxmox_api_url = "https://pve1.lobster:8006/"
protection      = false

# Set overrides if needed
rke2_nodes = {
  control-plane-0 = {
    clone_config = {
      vm_id = 1002
    }
    proxmox_node = "pve2"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "controlplane"
      host_vars = {
        is_primary          = true
        node_taints         = []
        kube_apiserver_args = []
      }
    }
  },
  control-plane-1 = {
    clone_config = {
      vm_id = 1003
    }
    proxmox_node = "pve3"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "controlplane"
      host_vars = {
        node_taints         = []
        kube_apiserver_args = []
      }
    }
  }
  control-plane-2 = {
    clone_config = {
      vm_id = 1002
    }
    proxmox_node = "pve2"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "controlplane"
      host_vars = {
        node_taints         = []
        kube_apiserver_args = []
      }
    }
  }
  worker-0 = {
    clone_config = {
      vm_id = 1003
    }
    cpu_config = {
      cores = 2
    }
    proxmox_node = "pve3"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_taints = []
      }
    }
  }
  worker-1 = {
    clone_config = {
      vm_id = 1003
    }
    cpu_config = {
      cores = 2
    }
    proxmox_node = "pve3"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_taints = []
      }
    }
  }
  worker-2 = {
    clone_config = {
      vm_id = 1002
    }
    cpu_config = {
      cores = 2
    }
    proxmox_node = "pve2"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_taints = []
      }
    }
  }
  worker-nexus-0 = {
    clone_config = {
      vm_id = 1002
    }
    cpu_config = {
      cores = 2
    }
    proxmox_node = "pve2"
    memory_config = {
      dedicated = 8192,
      floating  = 8192,
    }
    disks_config = [
      {
        size = "200"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_taints = [
          "is-nexus=true:NoSchedule"
        ]
      }
    }
  }
}
