output "tailscale_server_ip" {
  description = "The IP address of the RKE2 server VM."
  value       = proxmox_virtual_environment_vm.tailscale.ipv4_addresses
}
