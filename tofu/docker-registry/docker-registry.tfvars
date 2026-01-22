proxmox_api_url = "https://pve1.lobster.icu:8006/"
protection      = false
proxmox_node    = "pve1"

network_devices = [{
  mac_address = "BC:24:11:3F:4B:D6"
}]

# Set overrides if needed
clone_config = {
  vm_id = 1004
}
