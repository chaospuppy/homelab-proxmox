proxmox_api_url = "https://pve1.lobster.icu:8006/"
protection      = false

# Set overrides if needed
rke2_nodes = {
  control-plane-0 = {
    clone_config = {
      vm_id = 1001
    }
    proxmox_node = "pve1"
    memory_config = {
      dedicated = 12288,
      floating  = 12288,
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
        node_taints         = ["node-role.kubernetes.io/control-plane:NoSchedule"]
        node_labels         = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve1"]
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
      dedicated = 12288,
      floating  = 12288,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "controlplane"
      host_vars = {
        node_taints         = ["node-role.kubernetes.io/control-plane:NoSchedule"]
        node_labels         = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve3"]
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
      dedicated = 12288,
      floating  = 12288,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "controlplane"
      host_vars = {
        node_taints         = ["node-role.kubernetes.io/control-plane:NoSchedule"]
        node_labels         = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve2"]
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
      dedicated = 12288,
      floating  = 12288,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_labels = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve3"]
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
      dedicated = 12288,
      floating  = 12288,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_labels = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve3"]
        node_taints = []
      }
    }
  }
  worker-2 = {
    clone_config = {
      vm_id = 1002
    }
    cpu_config = {
      cores = 6
    }
    proxmox_node = "pve2"
    memory_config = {
      dedicated = 12288,
      floating  = 12288,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_labels = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve2"]
        node_taints = []
      }
    }
  }
  worker-3 = {
    clone_config = {
      vm_id = 1001
    }
    cpu_config = {
      cores = 6
    }
    proxmox_node = "pve1"
    memory_config = {
      dedicated = 12288,
      floating  = 12288,
    }
    disks_config = [
      {
        size = "100"
      }
    ]
    ansible_info = {
      group = "workers"
      host_vars = {
        node_labels = ["topology.kubernetes.io/region=lobster", "topology.kubernetes.io/zone=pve1"]
        node_taints = []
      }
    }
  }
}
